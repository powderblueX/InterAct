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
}

