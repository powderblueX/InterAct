//
//  AppDelegate.swift
//  EcoStep
//
//  Created by admin on 2024/11/23.
//

import UIKit
import LeanCloud
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    // 当应用启动完成时会调用
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 检测当前深色模式并更新图标
        updateAppIcon(for: UITraitCollection.current.userInterfaceStyle == .dark)
        
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
        
        return true
    }
    
    func updateAppIcon(for isDarkMode: Bool) {
        print("当前深色模式：\(isDarkMode ? "是" : "否")")
        guard UIApplication.shared.supportsAlternateIcons else {
            print("不支持动态图标切换:\(UIApplication.shared.supportsAlternateIcons)")
            return
        }
        let iconName = isDarkMode ? "DarkModeIcon" : nil
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("图标切换失败: \(error.localizedDescription)")
            } else {
                print("图标切换成功")
            }
        }
    }
    
    // 处理应用的深链接
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Received URL: \(url)")
        // 确保深链接的 scheme 和 host 正确
        if url.scheme == "XInterActApp" && url.host == "activity" {
            if let activityID = url.queryParameters?["id"] {
                // 更新全局状态，存储活动ID
                AppState.shared.activityIDToShow = activityID
                print("深链接解析，活动ID: \(activityID)")
            } else {
                print("没有找到活动ID")
            }
        } else {
            print("深链接不匹配 scheme 或 host")
        }
        return true
    }
}

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return nil }
        var params = [String: String]()
        for item in queryItems {
            params[item.name] = item.value
        }
        return params
    }
}

// TODO: 
//// 扩展 Notification.Name，用来定义深链接通知
//extension Notification.Name {
//    static let activityDeepLink = Notification.Name("activityDeepLink")
//}
