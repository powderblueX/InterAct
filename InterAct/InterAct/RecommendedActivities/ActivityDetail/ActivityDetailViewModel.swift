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
    
    func checkParticipantButtonDisabled() -> Bool {
        return ((activity?.hostId) == nil) || activity?.participantIds.count == activity?.participantsCount || checkIsCurrentUserInActivity()
    }
    
    func checkIsCurrentUserInActivity() -> Bool {
        if let isParticipant = activity?.participantIds.contains(currentUserId) {
            return isParticipant
        } else {
            return false
        }
    }
    
    func getCurrentId(){
        guard let objectId = UserDefaults.standard.string(forKey: "objectId") else {
            LeanCloudService.logout()
            return
        }
        currentUserId = objectId
    }
    
    // 生成深链接并分享或复制
    func shareOrCopyDeepLink(activityID: String) {
        guard let deepLinkURL = generateDeepLink(activityID: activityID) else {
            print("生成深链接失败")
            return
        }
        
        let shareOptions = [
            "分享到其他应用",
            "复制链接到剪切板"
        ]
        
        // 弹出选项表单
        let alertController = UIAlertController(
            title: "分享",
            message: "选择操作",
            preferredStyle: .actionSheet
        )
        
        // 分享选项
        let shareAction = UIAlertAction(title: shareOptions[0], style: .default) { _ in
            self.showShareSheet(with: deepLinkURL)
        }
        alertController.addAction(shareAction)
        
        // 复制选项
        let copyAction = UIAlertAction(title: shareOptions[1], style: .default) { _ in
            self.copyToClipboard(deepLinkURL.absoluteString)
        }
        alertController.addAction(copyAction)
        
        // 取消选项
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
        
        // 显示选项菜单
        if let topController = UIApplication.topViewController {
            topController.present(alertController, animated: true)
        }
    }
    
    /// 生成深链接
    private func generateDeepLink(activityID: String) -> URL? {
        var components = URLComponents()
        components.scheme = "XInterActApp"
        components.host = "activity"
        components.queryItems = [
            URLQueryItem(name: "id", value: activityID)
        ]
        return components.url
    }
    
    /// 显示分享面板
    private func showShareSheet(with url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let topController = UIApplication.topViewController {
            topController.present(activityViewController, animated: true)
        }
    }
    
    /// 复制链接到剪切板
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        print("链接已复制到剪切板: \(text)") // TODO: 
    }
    
    
}


extension UIApplication {
    static var topViewController: UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return nil
        }
        return window.rootViewController
    }
}
