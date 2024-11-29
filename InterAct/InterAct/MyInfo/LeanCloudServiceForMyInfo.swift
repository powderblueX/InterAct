//
//  LeanCloudServiceForMyInfo.swift
//  EcoStep
//
//  Created by admin on 2024/11/23.
//

import Foundation
import LeanCloud

class LeanCloudService {
    
    // 登录方法
    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        LCUser.logIn(username: username, password: password) { result in
            switch result {
            case .success:
                // 登录成功，将用户名存储到 UserDefaults
                UserDefaults.standard.set(username, forKey: "username")
                // 存储密码到 Keychain
                _ = KeychainHelper.savePassword(password: password)
                completion(.success(())) // 登录成功，返回 .success
            case .failure(let error):
                completion(.failure(error)) // 登录失败，返回 .failure 并传递错误
            }
        }
    }

    // 获取用户信息
    func fetchUserInfo(objectId: String, username: String, completion: @escaping (Result<MyInfoModel, Error>) -> Void) {
        let query = LCQuery(className: "_User")
        query.whereKey("objectId", .equalTo(objectId))
        
        query.find { result in
            switch result {
            case .success(let objects):
                guard let userObject = objects.first else {
                    completion(.failure(NSError(domain: "LeanCloudService", code: 404, userInfo: [NSLocalizedDescriptionKey: "用户未找到"])))
                    return
                }
                
                // 从查询结果中获取用户信息
                let email = userObject.email?.stringValue ?? ""
                let birthday = userObject.birthday?.dateValue ?? Date()
                let gender = userObject.gender?.stringValue ?? ""
                let interest: [String] = userObject.interest?.arrayValue as? [String] ?? ["无🚫"]
                let avatarURLString = userObject.avatarURL?.stringValue ?? ""
                // 如果 avatarURLString 有值，尝试转换为 URL
                let avatarURL = avatarURLString.isEmpty ? nil : URL(string: avatarURLString)
                
                let userInfo = MyInfoModel(
                    id: objectId,
                    username: username,
                    avatarURL: avatarURL,
                    email: email,
                    birthday: birthday,
                    gender: gender,
                    interest: interest,
                    posts: [], // 默认为空数组，后续可根据需要进行填充
                    favorites: [] // 同上
                )
                
                UserDefaults.standard.set(avatarURL, forKey: "avatarURL")
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(interest, forKey: "interest")
                UserDefaults.standard.set(birthday, forKey: "birthday")
                UserDefaults.standard.set(gender, forKey: "gender")
                // TODO: 将用户信息全部保存
                
                print(userInfo)
                completion(.success(userInfo))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // 更新用户信息
    func updateUserInfo(objectId: String, newInfo: MyInfoModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let query = LCQuery(className: "_User")
        query.whereKey("objectId", .equalTo(objectId))

        query.find { result in
            switch result {
            case .success(let objects):
                guard let userObject = objects.first else {
                    completion(.failure(NSError(domain: "LeanCloudService", code: 404, userInfo: [NSLocalizedDescriptionKey: "用户未找到"])))
                    return
                }

                do {
                    // 更新用户信息字段
                    try userObject.set("email", value: newInfo.email)
                    try userObject.set("birthday", value: newInfo.birthday)
                    try userObject.set("gender", value: newInfo.gender)

                    // 更新头像URL字段（如果有的话）
                    if let avatarURL = newInfo.avatarURL?.absoluteString {
                        try userObject.set("avatarURL", value: avatarURL)
                    }

                    // 保存更新后的用户对象
                    userObject.save { saveResult in
                        switch saveResult {
                        case .success:
                            completion(.success(())) // 更新成功
                        case .failure(let error):
                            completion(.failure(error)) // 更新失败
                        }
                    }
                } catch {
                    completion(.failure(error)) // 捕获 set 方法的错误
                }
                
            case .failure(let error):
                completion(.failure(error)) // 查询失败
            }
        }
    }


    // 登出方法
    func logout() {
        LCUser.logOut() // 退出当前用户
        UserDefaults.standard.removeObject(forKey: "username") // 移除用户名
        KeychainHelper.deletePassword() // 移除密码
    }
}
