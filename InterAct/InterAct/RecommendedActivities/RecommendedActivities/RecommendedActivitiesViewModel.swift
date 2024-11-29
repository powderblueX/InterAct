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
        let currentDate = Date()
        print("--------")
        print(currentDate)
        print("--------")
        // 使用 LeanCloud SDK 查询活动
        let query = LCQuery(className: "Activity")
        
        // 过滤兴趣标签匹配的活动
        query.whereKey("interestTag", .containedIn(interests))  // 查找兴趣标签包含在给定数组中的活动
        
        // 过滤活动时间晚于当前时间的活动
        query.whereKey("activityTime", .greaterThan(LCDate(currentDate))) // 活动时间必须在当前时间之后
        
        query.find { [self] result in
            switch result {
            case .success(let objects):
                // 将查询结果转化为 Activity 对象
                let fetchedActivities = objects.compactMap { object -> Activity? in
                    guard let activityName = object["activityName"]?.stringValue,
                          let interestTag = object["interestTag"]?.arrayValue,
                          let activityTime = object["activityTime"]?.dateValue,
                          let activityDescription = object["activityDescription"]?.stringValue,
                          let hostId = object["hostId"]?.stringValue,
                          let participantsCount = object["participantsCount"]?.intValue,
                          let participantIds = object["participantIds"]?.arrayValue,
                          let location = object["location"] as? LCGeoPoint
                    else {
                        return nil
                    }
                    
                    let imageURLString = object["image"]?.stringValue ?? ""
                    // 如果 avatarURLString 有值，尝试转换为 URL
                    let image = imageURLString.isEmpty ? nil : URL(string: imageURLString)
                    
                    // 创建 Activity 对象
                    return Activity(
                        id: object.objectId!.stringValue ?? "",
                        activityName: activityName,
                        interestTag: interestTag as? Array<String> ?? [],
                        activityTime: activityTime,
                        activityDescription: activityDescription,
                        hostId: hostId,
                        participantsCount: participantsCount,
                        participantIds: participantIds as? Array<String> ?? [],
                        location: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                        image: image  // 此处根据实际情况处理图片
                    )
                }
                
                // 更新活动列表
                DispatchQueue.main.async {
                    self.activities = fetchedActivities
                    print(self.activities)
                }
                
            case .failure(let error):
                // 错误处理
                DispatchQueue.main.async {
                    print("查询失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 加载所有活动数据（如果没有兴趣标签）
    func fetchAllActivities() {
        let currentDate = Date()
        // TODO: 校准时间
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        dateFormatter.timeZone = TimeZone.current // 设置为当前设备的时区
//        // 将 UTC 时间转换为本地时间
//        let localDateString = dateFormatter.string(from: currentDate)
        
        // 使用 LeanCloud SDK 查询所有活动
        let query = LCQuery(className: "Activity")
        
        // 过滤活动时间晚于当前时间的活动
        query.whereKey("activityTime", .greaterThan(LCDate(currentDate))) // 活动时间必须在当前时间之后
        
        query.find { result in
            switch result {
            case .success(let objects):
                // 将查询结果转化为 Activity 对象
                let fetchedActivities = objects.compactMap { object -> Activity? in
                    guard let activityName = object["activityName"]?.stringValue,
                          let interestTag = object["interestTag"]?.arrayValue,
                          let activityTime = object["activityTime"]?.dateValue,
                          let activityDescription = object["activityDescription"]?.stringValue,
                          let hostId = object["hostId"]?.stringValue,
                          let participantsCount = object["participantsCount"]?.intValue,
                          let participantIds = object["participantIds"]?.arrayValue,
                          let location = object["location"] as? LCGeoPoint
                    else {
                        return nil
                    }
                    
                    let imageURLString = object["image"]?.stringValue ?? ""
                    // 如果 avatarURLString 有值，尝试转换为 URL
                    let image = imageURLString.isEmpty ? nil : URL(string: imageURLString)
                    
                    // 创建 Activity 对象
                    return Activity(
                        id: object.objectId!.stringValue ?? "",
                        activityName: activityName,
                        interestTag: interestTag as? Array<String> ?? [],
                        activityTime: activityTime,
                        activityDescription: activityDescription,
                        hostId: hostId,
                        participantsCount: participantsCount,
                        participantIds: participantIds as? Array<String> ?? [],
                        location: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                        image: image  // 此处根据实际情况处理图片
                    )
                }
                
                // 更新活动列表
                DispatchQueue.main.async {
                    self.activities = fetchedActivities
                    print(self.activities)
                }
                
            case .failure(let error):
                // 错误处理
                DispatchQueue.main.async {
                    print("查询失败: \(error.localizedDescription)")
                }
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

