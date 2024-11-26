//
//  SettingsViewModel.swift
//  EcoStep
//
//  Created by admin on 2024/11/25.
//

import Foundation
import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {
    private let leanCloudService = LeanCloudService()
    @Published var showLogoutAlert = false // 控制退出登录确认弹窗
    
    func logout() {
        // 清除 LeanCloud 的会话
        leanCloudService.logout()
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
    
}
