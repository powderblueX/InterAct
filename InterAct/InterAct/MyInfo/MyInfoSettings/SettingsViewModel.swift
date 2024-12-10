//
//  SettingsViewModel.swift
//  InterAct
//
//  Created by admin on 2024/11/25.
//

import Foundation
import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {
    private let leanCloudService = LeanCloudService()
    @Published var showLogoutAlert = false // 控制退出登录确认弹窗
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    func logout() {
        // 清除 LeanCloud 的会话
        LeanCloudService.logout()
        // 清除 Keychain 中的密码
        KeychainHelper.deletePassword()
        
        // 清空 UserDefaults
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        
        // 同步操作
        UserDefaults.standard.synchronize()
        
        // 返回到登录页面
        withAnimation {
            AppState.shared.isLoggedIn = false // 假设用 AppState 控制登录状态
        }
    }
    
    func updateAppearance() {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        scene?.windows.forEach { window in
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }
    
    func switchToIcon(named iconName: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            print("当前设备不支持动态图标")
            return
        }
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("图标切换失败: \(error.localizedDescription)")
            } else {
                print("图标切换成功为: \(iconName ?? "默认图标")")
            }
        }
    }
}


