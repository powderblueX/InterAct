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
import LeanCloud

class CreateActivityViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var activityName: String = ""
    @Published var selectedTags: [String] = ["无🚫"] // 用户选择的兴趣标签数组
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
    @Published var islocationDistanceWarning: Bool = false
    @Published var locationDistanceWarning: String = "活动地点与发起人位置相距过远，可能不方便参与。" // 距离过远的提示信息
    @Published var isImagePickerPresented: Bool = false
    @Published var isImageEditingPresented: Bool = false
    @Published var isCreateSuccessfully: Bool = false
    
    private var hostId: String? {
        UserDefaults.standard.string(forKey: "objectId")
    }
    
    // 最多字符数
    let maxDescriptionLength = 200
    // 设置发起人位置与选择位置之间的最大距离（单位：米）
    private let maxDistance: Double = 1000
    // 引用Interest结构体
    let interest = Interest()
    
    // TODO: 添加一个经验值来限制活动数
    
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
            if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                DispatchQueue.global(qos: .background).async {
                    self.locationManager.startUpdatingLocation()
                }
            }
        }
    }
    
    // 停止更新位置
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // 地理编码：通过地址获取经纬度
//    func geocodeAddress(address: String) {
//        geocoder.geocodeAddressString(address) { [weak self] (placemarks, error) in
//            if let error = error {
//                print("Geocoding failed: \(error.localizedDescription)")
//                return
//            }
//            
//            if let placemark = placemarks?.first, let location = placemark.location {
//                // 更新选择的经纬度和名称
//                self?.location = location.coordinate
//                self?.selectedLocationName = placemark.name ?? "未知位置"
//            }
//        }
//    }
    
    // 选择地图位置
    func selectLocation(_ newLocation: CLLocationCoordinate2D) {
        location = newLocation
    }
    
    // 判断选择的活动地点与发起人位置的距离
    func updateLocationDistanceWarning() {
        guard let selectedLocation = location else { return }
        
        let hostCLLocation = CLLocation(latitude: hostLocation.latitude, longitude: hostLocation.longitude)
        let activityCLLocation = CLLocation(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude)
        
        let distance = hostCLLocation.distance(from: activityCLLocation)
        
        islocationDistanceWarning = distance > maxDistance
    }
    
    // 提交活动到LeanCloud
    func createActivity() {
        guard let hostId = hostId else {
            // TODO: 退出登录处理
            alertMessage = "用户数据出错，请重新登录"
            showAlert = true
            return
        }
        
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
        
        let activity = LCObject(className: "Activity")
        activity["activityName"] = LCString(activityName)
        activity["interestTag"] = LCArray(selectedTags.map { LCString($0) })
        activity["activityTime"] = LCDate(activityTime)
        activity["activityDescription"] = LCString(activityDescription)
        activity["hostId"] = LCString(hostId)
        activity["participantsCount"] = LCNumber(integerLiteral: participantsCount)
        activity["participantIds"] = LCArray([hostId]) // 参与者 ID 数组（可以根据用户数据填充）
        activity["location"] = LCGeoPoint(latitude: location?.latitude ?? 39.90750000, longitude: location?.longitude ?? 116.38805555)
        
        // 将 UIImage 转换为 JPEG 数据
        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            let file = LCFile(payload: .data(data: imageData))
                
            file.save { [self] result in
                switch result {
                case .success:
                    // 获取文件的 URL 字符串
                    if let fileUrl = file.url?.value {
                        let secureURL = fileUrl.replacingOccurrences(of: "http://", with: "https://")
                        activity["image"] = LCString(secureURL) // 保存文件 URL 到 LeanCloud
                        saveActivity(activity)  // 上传活动信息
                    } else {
                        self.alertMessage = "图片上传失败，无法获取文件 URL"
                        self.showAlert = true
                    }
                case .failure(let error):
                    self.alertMessage = "图片上传失败: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        } else {
            // 如果没有选择图片，直接保存活动信息
            saveActivity(activity)
        }
    }
    
    func saveActivity(_ activity: LCObject) {
        // 保存活动信息到 LeanCloud
        activity.save { result in
            switch result {
            case .success:
                self.isCreateSuccessfully = true
                self.alertMessage = "活动发布成功！"
                self.showAlert = true
            case .failure(let error):
                self.alertMessage = "发布失败: \(error.localizedDescription)"
                self.showAlert = true
            }
        }
    }
    
    // 使用 CLGeocoder 将经纬度转换为地名
    // 使用 MKLocalSearch 查找具体地标的名称
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


