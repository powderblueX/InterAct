//
//  EditUsernameEmailViewModel.swift
//  EcoStep
//
//  Created by admin on 2024/11/24.
//

import Foundation
import LeanCloud

class EditBaseUserInfoViewModel: ObservableObject {
    @Published var newUsername: String = ""
    @Published var birthday: Date = Date()
    @Published var gender: String = "男" // 默认值
    @Published var errorMessage: ErrorMessage?
    @Published var isButtonDisabled: Bool = true
    @Published var isUsernameEmailUpdated: Bool = false
    @Published var alertType: AlertType? // 统一管理弹窗类型

    private var objectId: String? {
        UserDefaults.standard.string(forKey: "objectId")
    }

    // 初始化输入字段
    func initializeFields(with userInfo: MyProfileModel?) {
        newUsername = userInfo?.username ?? ""
        //newEmail = userInfo?.email ?? ""
        birthday = userInfo?.birthday ?? Date()
        gender = userInfo?.gender ?? "男"
        validateFields()
    }

    // 验证字段内容
    private func validateFields() {
        isButtonDisabled = newUsername.isEmpty
    }

    // 保存修改到 LeanCloud
    func saveChanges(completion: @escaping (Bool) -> Void) {
        LeanCloudService.saveChanges(objectId: objectId, newUsername: newUsername, birthday: birthday, gender: gender) { [weak self] success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    // 更新 UI
                    self?.isUsernameEmailUpdated = true
                    self?.alertType = .success("基本信息更新成功")
                    
                    // 更新 UserDefaults
                    UserDefaults.standard.set(self?.newUsername, forKey: "username")
                    UserDefaults.standard.set(self?.birthday, forKey: "birthday")
                    UserDefaults.standard.set(self?.gender, forKey: "gender")
                } else {
                    // 处理错误
                    self?.alertType = .error(errorMessage ?? "保存失败")
                }
            }
        }
    }
}

