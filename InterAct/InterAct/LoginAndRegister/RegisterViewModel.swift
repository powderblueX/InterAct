//
//  RegisterViewModel.swift
//  EcoStep
//
//  Created by admin on 2024/11/23.
//

import SwiftUI

class RegisterViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var email: String = ""
    @Published var gender: String = "男"
    @Published var birthday: Date = Date()
    @Published var errorMessage: String = ""
    @Published var isRegistering: Bool = false
    @Published var alertMessage: String = ""// 提示框显示的消息
    @Published var showAlert: Bool = false // 用来控制提示框显示
    
    @Published var confirmPassword: String = ""
    private var userModel: UserModel
    
    init(userModel: UserModel = UserModel()) {
        self.userModel = userModel
    }
    
    func register(isFormValid: Bool) {
        // 清除之前的错误信息
        errorMessage = ""
        
        guard isFormValid else {
            self.errorMessage = "请填写完整的表单"
            return
        }
        
        // 检查密码是否匹配
        guard self.password == self.confirmPassword else {
            self.errorMessage = "两次输入的密码不一致"
            return
        }
        
        // 开始注册
        isRegistering = true
        userModel.register(username: username, password: password, email: email, gender: gender, birthday: birthday) { result in
            DispatchQueue.main.async {
                self.isRegistering = false
                switch result {
                case .success(let user):
                    // 注册成功
                    self.alertMessage = "注册成功！"
                    self.showAlert = true
                    print("User registered: \(user)") // 输出注册的用户对象
                case .failure(let error):
                    // 注册失败
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // 重置所有字段
    func reset() {
        username = ""
        password = ""
        confirmPassword = ""
        email = ""
        gender = "男"
        birthday = Date()
        errorMessage = ""
    }
}
