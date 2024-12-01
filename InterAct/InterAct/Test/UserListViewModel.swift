//
//  UserListViewModel.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import Foundation

import Foundation
import LeanCloud

class UserListViewModel: ObservableObject {
    @Published var userInfo: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // 从 LeanCloud 加载用户列表
    func loadUsers(objectId: String, completion: @escaping (Result<User, Error>) -> Void) {
        let query = LCQuery(className: "_User")  // LeanCloud 中的 User 表名是 _User
        query.whereKey("objectId", .equalTo(objectId))
        
        query.find { result in
            switch result {
            case .success(let objects):
                guard let userObject = objects.first else {
                    completion(.failure(NSError(domain: "LeanCloudService", code: 404, userInfo: [NSLocalizedDescriptionKey: "用户未找到"])))
                    return
                }
                
                // 从查询结果中获取用户信息
                let username = userObject.username?.stringValue ?? ""
                let email = userObject.email?.stringValue ?? ""
                let birthday = userObject.birthday?.dateValue ?? Date()
                let gender = userObject.gender?.stringValue ?? ""
                let interest: [String] = userObject.interest?.arrayValue as? [String] ?? ["无🚫"]
                let avatarURLString = userObject.avatarURL?.stringValue ?? ""
                // 如果 avatarURLString 有值，尝试转换为 URL
                let avatarURL = avatarURLString.isEmpty ? nil : URL(string: avatarURLString)
                
                let userInfo = User(
                    id: objectId,
                    username: username,
                    avatarURL: avatarURL,
                    email: email,
                    birthday: birthday,
                    gender: gender,
                    interest: interest
                )
                
                UserDefaults.standard.set(avatarURL, forKey: "avatarURL")
                
                print(userInfo)
                completion(.success(userInfo))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
