//
//  AppDelegate.swift
//  EcoStep
//
//  Created by admin on 2024/11/23.
//

import UIKit
import LeanCloud

class AppDelegate: NSObject, UIApplicationDelegate {
    // 当应用启动完成时会调用
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // LeanCloud 初始化代码
        do {
            try LCApplication.default.set(
                id: "TJMdb14PZAk2ZMkf41nLWKDW-gzGzoHsz",           // LeanCloud App ID
                key: "9AxeJKCHR8tdD4bIQEgiu6Rv",         // LeanCloud App Key
                serverURL: "https://tjmdb14p.lc-cn-n1-shared.com" // LeanCloud 服务地址
            )
        } catch {
            print("LeanCloud 初始化失败：\(error)")
        }
        // 请求推送通知权限
        requestPushNotificationPermission()
        
        return true
    }
    
    // 请求推送通知权限
    private func requestPushNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("推送通知权限已授权")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("推送通知权限未授权")
            }
        }
    }
    
    // 注册远程通知成功，获取 deviceToken
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 将 deviceToken 转换为字符串并存储
        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        UserDefaults.standard.set(deviceTokenString, forKey: "deviceToken")
        print("设备注册成功，deviceToken: \(deviceTokenString)")
        
        // 获取当前用户的 objectId
        if let userId = UserDefaults.standard.string(forKey: "objectId") {
            // 将 deviceToken 存储到 _Installation 表中
            saveDeviceTokenToInstallation(deviceToken: deviceTokenString, userId: userId)
        }
    }
    
    // 注册远程通知失败
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("远程通知注册失败：\(error.localizedDescription)")
    }

    // 将 deviceToken 存储到 LeanCloud _Installation 表，并与 userId 关联
    func saveDeviceTokenToInstallation(deviceToken: String, userId: String) {
        let installation = LCInstallation()
        installation.set(deviceToken: "deviceToken", apnsTeamId: deviceToken)  // 设置 deviceToken
        installation.set(deviceToken: "userId", apnsTeamId: userId)  // 将 userId 设置为设备的关联标识
        
        installation.save { result in
            switch result {
            case .success:
                print("Device token 保存成功.")
            case .failure(let error):
                print("保存 device token 失败：\(error)")
            }
        }
    }
    
    // 处理收到的远程推送通知
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // 解析推送通知
        if let aps = userInfo["aps"] as? [String: AnyObject], let alert = aps["alert"] as? String {
            print("Received push notification: \(alert)")
            
            // 在界面上显示推送通知消息
            DispatchQueue.main.async {
                // 假设你有一个界面组件来显示消息
                // 例如弹出一个对话框或更新界面
                self.showAlert(message: alert)
            }
        }
        
        completionHandler(.newData)
    }
        
        // 显示消息的简单实现
    func showAlert(message: String) {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let rootVC = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                let alert = UIAlertController(title: "Push Notification", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                rootVC.present(alert, animated: true, completion: nil)
            }
        }
    }
}

