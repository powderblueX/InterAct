//
//  ChangePasswordViewModel.swift
//  EcoStep
//
//  Created by admin on 2024/11/24.
//

import Foundation
import Combine
import LeanCloud

class ChangePasswordViewModel: ObservableObject {
    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: ErrorMessage?
    @Published var isPasswordUpdated: Bool = false
    @Published var alertType: AlertType? // 统一管理弹窗类型

    private var cancellables = Set<AnyCancellable>()

    // 更新密码逻辑
    func updatePassword() {
        guard let objectId = UserDefaults.standard.string(forKey: "objectId") else {
            LeanCloudService.logout()
            self.alertType = .error("用户未登录，无法获取用户ID")
            return
        }
        
        // 从 Keychain 中读取保存的密码
        guard let savedPassword = KeychainHelper.loadPassword() else {
            alertType = .error("无法从 Keychain 中读取当前密码，请重新登录")
            return
        }
        
        // 验证当前密码是否匹配
        guard savedPassword == currentPassword else {
            alertType = .error("当前密码不正确")
            return
        }
        
        // 验证新密码是否匹配
        guard newPassword == confirmPassword else {
            alertType = .error("新密码和确认密码不一致")
            return
        }
        
        // 当前密码验证通过，调用 LeanCloudService 更新密码
        LeanCloudService.updatePassword(objectId: objectId, newPassword: newPassword) { [weak self] success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    self?.isPasswordUpdated = true
                    self?.alertType = .success("密码更新成功")
                    // 同步保存新密码到 Keychain
                    self?.saveNewPasswordToKeychain(self?.newPassword ?? "")
                } else {
                    self?.alertType = .error(errorMessage ?? "密码更新失败")
                }
            }
        }
    }
    
    // 将新密码保存到 Keychain
    private func saveNewPasswordToKeychain(_ newPassword: String) {
        let success = KeychainHelper.savePassword(password: newPassword)
        if !success {
            self.alertType = .error("密码更新成功，但无法保存新密码到本地")
        }
    }
}
