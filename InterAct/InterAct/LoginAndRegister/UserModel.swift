//
//  UserModel.swift
//  EcoStep
//
//  Created by admin on 2024/11/23.
//

import Foundation
import LeanCloud

class UserModel {
    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // LCUser.logIn 是异步方法，不会抛出错误，因此直接调用即可
        LCUser.logIn(username: username, password: password) { result in
            switch result {
            case .success(let user):
                // 确保获取当前用户
                guard let objectId = user.objectId?.value else {
                    completion(.failure(NSError(domain: "LoginError", code: 0, userInfo: [NSLocalizedDescriptionKey: "无法获取用户ID"])))
                    return
                }
                // 登录成功，将ID，用户名存储到 UserDefaults
                UserDefaults.standard.set(objectId, forKey: "objectId")
                UserDefaults.standard.set(username, forKey: "username")
                // 存储密码到 Keychain
                if !KeychainHelper.savePassword(password: password) {
                    completion(.failure(NSError(domain: "KeychainError", code: 0, userInfo: [NSLocalizedDescriptionKey: "无法保存密码"])))
                    return
                }
                completion(.success(())) // 登录成功，返回 .success
            case .failure(let error):
                completion(.failure(error)) // 登录失败，返回 .failure 并传递错误
            }
        }
    }

    
    func register(username: String, password: String, email: String, gender: String, birthday: Date, completion: @escaping (Result<LCUser, Error>) -> Void) {
        // 创建 LeanCloud 用户对象
        let user = LCUser()
        user.username = LCString(username)
        user.password = LCString(password)
        user.email = LCString(email)
        
        // 设置性别和生日
        do {
            try user.set("gender", value: LCString(gender))
            try user.set("birthday", value: LCDate(birthday))
            
            // 注册用户
            user.signUp { result in
                switch result {
                case .success:
                    // 注册成功
                    completion(.success(user)) // 返回成功的用户对象
                case .failure(let error):
                    // 注册失败，返回错误
                    completion(.failure(error))
                }
            }
        } catch {
            // 捕捉配置字段的错误
            completion(.failure(error))
        }
    }
}

