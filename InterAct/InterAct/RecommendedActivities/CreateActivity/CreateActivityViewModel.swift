//
//  CreateActivityViewModel.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import Foundation
import CoreLocation
import SwiftUI
import MapKit

class CreateActivityViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var activityName: String = ""
    @Published var selectedTags: [String] = [] // 用户选择的兴趣标签数组
    @Published var activityTime: Date = Date()
    @Published var participantsCount: Int = 10
    @Published var activityDescription: String = ""
    @Published var selectedImage: UIImage? = nil // 上传的照片（非必填项）
    @Published var location: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 39.90750000, longitude: 116.38805555)
    @Published var hostLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 39.90750000, longitude: 116.38805555) // 默认发起人位置
    @Published var showAlert: Bool = false // 弹窗显示标志
    @Published var alertMessage: String = ""
    @Published var selectedLocationName: String = "未选择位置" // 存储选中的地名
    
    @Published var activityTimeError: String? = nil
    @Published var activityNameError: String? = nil
    @Published var activityDescriptionError: String? = nil
    @Published var locationError: String? = nil
    
    // 最多字符数
    let maxDescriptionLength = 200
    // 设置发起人位置与选择位置之间的最大距离（单位：米）
    private let maxDistance: Double = 1000
    // 引用Interest结构体
    let interest = Interest()
    
    // 用于地理编码
    private let geocoder = CLGeocoder()
   
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
        self.location = newLocation.coordinate
        self.hostLocation = newLocation.coordinate
        
        // 可以选择通过地理编码获取地点名称
        reverseGeocodeLocation(newLocation.coordinate)
    }
    
    // 获取失败时的处理
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.alertMessage = "定位失败: \(error.localizedDescription)"
        self.showAlert = true
    }
    
    // 开始更新位置
    func startUpdatingLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    // 停止更新位置
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // 地理编码：通过地址获取经纬度
    func geocodeAddress(address: String) {
        geocoder.geocodeAddressString(address) { [weak self] (placemarks, error) in
            if let error = error {
                print("Geocoding failed: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                // 更新选择的经纬度和名称
                self?.location = location.coordinate
                self?.selectedLocationName = placemark.name ?? "未知位置"
            }
        }
    }
    
    // 选择地图位置
    func selectLocation(_ newLocation: CLLocationCoordinate2D) {
        location = newLocation
    }
    
    // 判断选择的活动地点与发起人位置的距离
    func validateLocation() -> Bool {
        let hostCLLocation = CLLocation(latitude: hostLocation.latitude, longitude: hostLocation.longitude)
        let activityCLLocation = CLLocation(latitude: location?.latitude ?? 39.90750000, longitude: location?.longitude ?? 116.38805555)
        
        let distance = hostCLLocation.distance(from: activityCLLocation)
        
        if distance > maxDistance {
            alertMessage = "活动地点与发起人位置相距过远，是否继续发布？"
            showAlert = true
            return false
        }
        return true
    }
    
    // 提交活动到LeanCloud
    func createActivity(creatorId: String) {
        // 检查数据是否有效
        if activityName.isEmpty {
            alertMessage = "标题不能为空"
            showAlert = true
            return
        }
        
        // 检查时间是否合适
        if activityTime < Date() {
            alertMessage = "时间不合适"
            showAlert = true
            return
        }
        
        // 检查数据是否有效
        if activityDescription.isEmpty {
            alertMessage = "简介不能为空"
            showAlert = true
            return
        }
        
        // 验证地点是否合适
        guard validateLocation() else { return }
        
        // 创建活动对象
        let activity = Activity(
            id: UUID().uuidString,
            activityName: activityName,
            interestTag: selectedTags, // 使用选择的标签数组
            activityTime: activityTime,
            activityDescription: activityDescription,
            hostId: creatorId,
            participantsCount: participantsCount,
            participantIds: [], // 初始化为空，实际可以根据用户数据填充
            location: location ?? CLLocationCoordinate2D(latitude: 39.90750000, longitude: 116.38805555),
            hostLocation: hostLocation,
            image: selectedImage
        )
        
        // 将活动数据提交到LeanCloud（模拟）
        submitActivityToLeanCloud(activity)
    }
    
    // 模拟提交到LeanCloud
    private func submitActivityToLeanCloud(_ activity: Activity) {
        // 在这里实现LeanCloud的API调用代码，提交活动数据
        print("Activity created: \(activity)")
        // 假设提交成功
        alertMessage = "活动发布成功！"
        showAlert = true
    }
    
    // 使用 CLGeocoder 将经纬度转换为地名
    //使用 MKLocalSearch 查找具体地标的名称
    func reverseGeocodeLocation(_ location: CLLocationCoordinate2D) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "博物馆" // 可以尝试更具体的搜索关键字
        searchRequest.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)) // 限定搜索范围
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let error = error {
                print("搜索失败: \(error.localizedDescription)")
                self.selectedLocationName = "无法获取地名"
                return
            }

            if let mapItem = response?.mapItems.first {
                self.selectedLocationName = mapItem.placemark.name ?? "未找到详细地点"
            } else {
                self.selectedLocationName = "未找到匹配地点"
            }
        }
    }
}


