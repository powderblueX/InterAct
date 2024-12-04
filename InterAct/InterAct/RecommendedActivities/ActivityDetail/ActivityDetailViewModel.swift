//
//  ActivityDetailViewModel.swift
//  InterAct
//
//  Created by admin on 2024/11/29.
//

import Foundation
import CoreLocation
import MapKit

class ActivityDetailViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var activity: Activity? = nil
    @Published var hostInfo: HostInfo? = nil
    @Published var currentUserId: String = ""
    @Published var myCLLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 39.90750000, longitude: 116.38805555) // 默认发起人位置
    @Published var directions: [MKRoute] = []
    
    @Published var isImageSheetPresented: Bool = false
    @Published var showSaveImageAlert: Bool = false
    @Published var showProfileBubble: Bool = false
    @Published var profileBubblePosition: CGPoint = .zero
    @Published var showMap: Bool = false
    @Published var showParticipateAlert: Bool = false
    
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
    
    func fetchActivityDetail(activityId: String) {
        // 使用 LeanCloud SDK 获取活动详情
        LeanCloudService.fetchActivityDetails(activityId: activityId) { [weak self] result in
            switch result {
            case .success(let activity):
                self?.activity = activity
            case .failure(let error):
                print("获取活动详情失败: \(error)")
            }
        }
    }
    
    func fetchHostInfo(for userId: String) {
        // 调用 LeanCloudService 来获取用户信息（用户名和头像URL）
        LeanCloudService.fetchHostInfo(for: userId) { [weak self] username, avatarURL, gender, exp in
            // 更新 PrivateChat 实例
            self?.hostInfo = HostInfo(
                username: username,
                avatarURL: URL(string: avatarURL),
                gender: gender,
                exp: exp
            )
        }
    }
    
    func getCurrentId(){
        guard let objectId = UserDefaults.standard.string(forKey: "objectId") else {
            LeanCloudService.logout()
            return
        }
        currentUserId = objectId
    }
}
