//
//  LoginViewModel.swift
//  EcoStep
//
//  Created by admin on 2024/11/23.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String? = nil
    @Published var isLogining: Bool = false
    @Published var alertMessage: String = ""// 提示框显示的消息
    @Published var showAlert: Bool = false // 用来控制提示框显示
    
    private let userModel = UserModel()
    
    func login() {
        guard !username.isEmpty else {
            errorMessage = "用户名不能为空"
            return
        }
        guard !password.isEmpty else {
            errorMessage = "密码不能为空"
            return
        }
        
        isLogining = true
        errorMessage = nil
        
        userModel.login(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLogining = false
                switch result {
                case .success:
                    AppState.shared.isLoggedIn = true
                    print("isLoggedIn 状态更新为: \(AppState.shared.isLoggedIn)")
                    self?.alertMessage = "登录成功！"
                    self?.showAlert = true
                    print("登录成功！")
                case .failure(let error):
                    if (error as NSError).code == 101 {
                        self?.errorMessage = "用户名或密码错误"
                    } else {
                        self?.errorMessage = "登录失败：\(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    // 自动登录
    func autoLogin() {
        if let savedUsername = UserDefaults.standard.string(forKey: "username"),
           let savedPassword = KeychainHelper.loadPassword() {
            username = savedUsername
            password = savedPassword
            login()
        }
    }
}

