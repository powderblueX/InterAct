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

// 推荐活动视图模型
class RecommendedActivitiesViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var activities: [Activity] = []
    @Published var searchText: String = ""
    @Published var myCLLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 39.90750000, longitude: 116.38805555) // 默认发起人位置

    // CLLocationManager 实例
    private var locationManager = CLLocationManager()
    
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
        // 从 UserDefaults 获取用户兴趣标签
        if let interests = UserDefaults.standard.array(forKey: "interest") as? [String], !interests.isEmpty {
                    // 检查是否包含 "无🚫" 标签
                    if interests.contains("无🚫") {
                        // 如果包含 "无🚫"，则加载所有活动
                        fetchAllActivities()
                    } else {
                        // 否则，根据用户的兴趣标签加载相应的活动
                        fetchActivitiesByInterests(interests: interests)
                    }
        } else {
            // 如果没有兴趣标签，则加载所有活动
            fetchAllActivities()
        }
    }
    
    // 根据兴趣标签从数据库获取活动
    func fetchActivitiesByInterests(interests: [String]) {
        // 调用 LeanCloudService 来获取活动
        LeanCloudService.fetchActivitiesByInterests(interests: interests) { [weak self] fetchedActivities in
            guard let self = self else { return }
            
            // 更新活动列表
            if let activities = fetchedActivities {
                self.activities = activities
                print("Fetched Activities: \(self.activities)")
            } else {
                print("没有找到活动")
            }
        }
    }
    
    // 加载所有活动数据（如果没有兴趣标签）
    func fetchAllActivities() {
        // 调用 LeanCloudService 来获取活动
        LeanCloudService.fetchAllActivities() { [weak self] fetchedActivities in
            guard let self = self else { return }
            
            // 更新活动列表
            if let activities = fetchedActivities {
                self.activities = activities
                print("Fetched Activities: \(self.activities)")
            } else {
                print("没有找到活动")
            }
        }
    }
    
    // 搜索活动
    func searchActivities() {
        if searchText.isEmpty {
            fetchActivities() // 如果没有搜索文本，重新加载所有活动
        } else {
            // 根据搜索文本过滤活动
            activities = activities.filter {
                $0.activityName.lowercased().contains(searchText.lowercased()) || $0.interestTag.contains { tag in
                    tag.lowercased().contains(searchText.lowercased())
                }
            }
        }
    }
    
    func LocationDistance(location: CLLocationCoordinate2D) -> String{
        let myCLLocation = CLLocation(latitude: myCLLocation.latitude, longitude: myCLLocation.longitude)
        let activityCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        return String(format: "%.3f", myCLLocation.distance(from: activityCLLocation) / 1000)
    }
    
    func getparticipantsCountColor(isFull: Bool) -> Color {
        return isFull ? .red : .blue
    }
}

