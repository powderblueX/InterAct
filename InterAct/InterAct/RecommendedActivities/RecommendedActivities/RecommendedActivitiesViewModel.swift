//
//  RecommendedActivitiesViewModel.swift
//  InterAct
//
//  Created by admin on 2024/11/28.
//

import Foundation
import CoreLocation
import SwiftUI
import LeanCloud

// TODO: 懒加载有bug, 置顶

// 推荐活动视图模型
class RecommendedActivitiesViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var activities: [Activity] = []
    @Published var searchText: String = ""
    @Published var myCLLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 39.90750000, longitude: 116.38805555) // 默认发起人位置
    @Published var showingCreateActivityView: Bool = false
    @Published var useInterestFilter: Bool = true
    private let timeWeight: Double = 0.5  // 时间的权重
    private let distanceWeight: Double = 0.5  // 距离的权重
    
    // 分页相关
    @Published var currentPage: Int = 1        // 当前页数
    @Published var totalPages = 1      // 每次加载的活动数量
    @Published var isLoading: Bool = false    // 标记是否正在加载数据
    @Published var isLoadingMore: Bool = false // 是否正在加载更多数据
    @Published var hasMoreData: Bool = true // 是否还有更多数据
    @Published var isForMore: Bool = false

    private let pageSize = 10 // 每页加载8条活动
    
    private var locationManager = CLLocationManager() // CLLocationManager 实例
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // 请求授权
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation() // 开始位置更新
    }
    
    // 获取设备当前位置
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.first else { return }
        
        // 更新设备当前位置信息
        self.myCLLocation = newLocation.coordinate
    }
    
    // 初始化时从 LeanCloud 获取兴趣标签匹配的活动
    func fetchActivities() {
        guard !isLoading else { return } // 如果正在加载，则不重复请求
                
        isLoading = true // 标记为正在加载
        
        // 从 UserDefaults 获取用户兴趣标签
        if let interests = UserDefaults.standard.array(forKey: "interest") as? [String], !interests.isEmpty {
            // 检查是否包含 "无🚫" 标签
            if interests.contains("无🚫") {
                // 如果包含 "无🚫"，则加载所有活动
                fetchAllActivities(page: currentPage)
            } else if useInterestFilter {
                // 否则，根据用户的兴趣标签加载相应的活动
                fetchActivitiesByInterests(interests: interests, page: currentPage)
            }
            else {
                // 用户有特别的兴趣标签但依然选择加载所有活动
                fetchAllActivities(page: currentPage)
            }
        } else {
            // 如果没有兴趣标签，则加载所有活动
            fetchAllActivities(page: currentPage)
        }
    }
    
    // 根据兴趣标签从数据库获取活动
    func fetchActivitiesByInterests(interests: [String], page: Int) {
        // 调用 LeanCloudService 来获取活动
        LeanCloudService.fetchActivitiesByInterests(interests: interests, page: page, pageSize: pageSize) { [weak self] fetchedActivities, totalPages  in
            guard let self = self else { return }

            self.isLoading = false
            
            // 更新活动列表
            if let activities = fetchedActivities {
                if page == 1 {
                    self.activities = activities // 如果是第一页，替换活动列表
                } else if hasMoreData && isForMore {
                    self.activities.append(contentsOf: activities) // 如果是后续页，追加活动
                    isForMore = false
                }
                self.totalPages = totalPages
                self.hasMoreData = self.currentPage < self.totalPages
                self.sortActivities()
            } else {
                print("没有找到活动")
            }
        }
    }
    
    // 加载所有活动数据（如果没有兴趣标签）
    func fetchAllActivities(page: Int) {
        // 调用 LeanCloudService 来获取活动
        LeanCloudService.fetchAllActivities(page: page, pageSize: pageSize) { [weak self] fetchedActivities, totalPages in
            guard let self = self else { return }
            
            self.isLoading = false
            
            // 更新活动列表
            if let activities = fetchedActivities {
                if page == 1 {
                    self.activities = activities // 如果是第一页，替换活动列表
                } else if hasMoreData && isForMore {
                    self.activities.append(contentsOf: activities) // 如果是后续页，追加活动
                    isForMore = false
                }
                self.totalPages = totalPages
                self.hasMoreData = self.currentPage < self.totalPages
                self.sortActivities()
            } else {
                print("没有找到活动")
            }
        }
    }
    
    // 加载更多数据
    func loadMoreActivities() {
        guard !isLoading && hasMoreData else { return }
        
        isLoadingMore = true
        currentPage += 1
        isForMore = true
        fetchActivities() // 继续加载活动
        isLoadingMore = false
    }
    
    // 搜索活动
    func searchActivities() {
        if !searchText.isEmpty {
            // 根据搜索文本过滤活动
            activities = activities.filter {
                $0.activityName.lowercased().contains(searchText.lowercased()) || $0.interestTag.contains { tag in
                    tag.lowercased().contains(searchText.lowercased())
                }
            }
        }
    }
    
    func SortLocationDistance(location: CLLocationCoordinate2D) -> Double {
        let myCLLocation = CLLocation(latitude: myCLLocation.latitude, longitude: myCLLocation.longitude)
        let activityCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return myCLLocation.distance(from: activityCLLocation)
    }
    
    func LocationDistance(location: CLLocationCoordinate2D) -> String{
        let myCLLocation = CLLocation(latitude: myCLLocation.latitude, longitude: myCLLocation.longitude)
        let activityCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        return String(format: "%.3f", myCLLocation.distance(from: activityCLLocation) / 1000)
    }
    
    // 综合排序：根据时间和距离排序
    func sortActivities() {
        let currentDate = Date()
        
        activities.sort { (activity1, activity2) -> Bool in
            // 计算时间得分
            let timeDiff1 = activity1.activityTime.timeIntervalSince(currentDate)
            let timeDiff2 = activity2.activityTime.timeIntervalSince(currentDate)
            
            // 归一化时间差，假设最大时间差为一周（以秒为单位）
            let maxTimeDiff: Double = 604800 // 一周的秒数
            let timeScore1 = max(0, 1 - (timeDiff1 / maxTimeDiff))
            let timeScore2 = max(0, 1 - (timeDiff2 / maxTimeDiff))
            
            // 计算距离得分
            let distance1 = SortLocationDistance(location: activity1.location)
            let distance2 = SortLocationDistance(location: activity2.location)
            let maxDistance: Double = 50000 // 最大距离为50公里
            let distanceScore1 = max(0, 1 - (distance1 / maxDistance))
            let distanceScore2 = max(0, 1 - (distance2 / maxDistance))
            
            // 综合得分
            let score1 = timeScore1 * timeWeight + distanceScore1 * distanceWeight
            let score2 = timeScore2 * timeWeight + distanceScore2 * distanceWeight
            
            return score1 > score2 // 排序：得分高的排在前面
        }
    }
    

    func getparticipantsCountColor(isFull: Bool) -> Color {
        return isFull ? .red : .blue
    }
}

