//
//  LeanCloudService.swift
//  InterAct
//
//  Created by admin on 2024/11/30.
//

import Foundation
import LeanCloud
import CoreLocation
import UIKit

struct LeanCloudService {
    // 用户登录
    static func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    
    // 用户注册
    static func register(username: String, password: String, email: String, gender: String, birthday: Date, completion: @escaping (Result<LCUser, Error>) -> Void) {
        // 创建 LeanCloud 用户对象
        let user = LCUser()
        user.username = LCString(username)
        user.password = LCString(password)
        user.email = LCString(email)
        
        // 设置性别和生日
        do {
            try user.set("gender", value: LCString(gender))
            try user.set("birthday", value: LCDate(birthday))
            try user.set("exp", value: LCNumber(integerLiteral: 0))
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
    
    
    // 获取用户信息
    static func fetchUserInfo(objectId: String, username: String, completion: @escaping (Result<MyInfoModel, Error>) -> Void) {
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
                let exp: Int = userObject.exp?.intValue ?? 0
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
                    exp: exp
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
    static func updateUserInfo(objectId: String, newInfo: MyInfoModel, completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    
    // 用户登出
    static func logout() {
        LCUser.logOut() // 退出当前用户
        UserDefaults.standard.removeObject(forKey: "objectId") // 移除用户id
        UserDefaults.standard.removeObject(forKey: "username") // 移除用户名
        UserDefaults.standard.removeObject(forKey: "avatarURL") // 移除用户名
        UserDefaults.standard.removeObject(forKey: "email") // 移除用户名
        UserDefaults.standard.removeObject(forKey: "interest") // 移除用户名
        UserDefaults.standard.removeObject(forKey: "birthday") // 移除用户名
        UserDefaults.standard.removeObject(forKey: "gender") // 移除用户名
        KeychainHelper.deletePassword() // 移除密码
        IMClientManager.shared.closeClient()
    }
    
    
    // 用户基本信息更新
    static func saveChanges(objectId: String?, newUsername: String, newEmail: String, birthday: Date, gender: String, completion: @escaping (Bool, String?) -> Void) {
        // 检查用户名和邮箱是否为空
        guard !newUsername.isEmpty, !newEmail.isEmpty else {
            completion(false, "用户名和邮箱不能为空")
            return
        }
        
        // 检查是否已登录（objectId 必须存在）
        guard let objectId = objectId else {
            logout()
            completion(false, "用户未登录")
            return
        }
        
        // 创建 LCObject 来更新用户信息
        let user = LCObject(className: "_User", objectId: LCString(objectId))
        
        // 设置要更新的字段
        do {
            try user.set("username", value: newUsername)
            try user.set("email", value: newEmail)
            try user.set("birthday", value: LCDate(birthday))
            try user.set("gender", value: gender)
        } catch {
            completion(false, "字段设置失败：\(error.localizedDescription)")
            return
        }
        
        // 保存数据到 LeanCloud
        user.save { result in
            switch result {
            case .success:
                completion(true, nil)
            case .failure(let error):
                completion(false, "保存失败：\(error.localizedDescription)")
            }
        }
    }
    
    
    // 用户兴趣更新
    static func saveChanges(objectId: String?, selectedInterests: [String], completion: @escaping (Bool, String) -> Void) {
        guard let objectId = objectId else {
            logout()
            completion(false, "用户未登录")
            return
        }
        
        do {
            let user = LCObject(className: "_User", objectId: LCString(objectId))
            try user.set("interest", value: selectedInterests)
            
            user.save { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        completion(true, "用户兴趣更新成功")
                    case .failure(let error):
                        completion(false, "保存失败：\(error.localizedDescription)")
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion(false, "保存失败：\(error.localizedDescription)")
            }
        }
    }
    
    
    // 用户密码更新
    static func updatePassword(objectId: String?, newPassword: String, completion: @escaping (Bool, String?) -> Void) {
        guard let objectId = objectId else {
            completion(false, "用户未登录，无法获取用户ID")
            return
        }
        
        do {
            let user = LCObject(className: "_User", objectId: LCString(objectId))
            try user.set("password", value: newPassword)
            
            user.save { result in
                switch result {
                case .success:
                    completion(true, "密码更新成功")
                case .failure(let error):
                    completion(false, "更新失败：\(error.localizedDescription)")
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion(false, "更新失败：\(error.localizedDescription)")
            }
        }
    }
    
    
    // 用户头像更新
    static func uploadAvatar(image: UIImage, objectId: String?, completion: @escaping (Bool, String?, String?) -> Void) {
        guard let objectId = objectId else {
            completion(false, "无法获取用户ID", nil)
            return
        }
        
        // 将 UIImage 转换为 JPEG 数据
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(false, "图片处理失败", nil)
            return
        }
        
        // 创建 LeanCloud 文件对象
        let file = LCFile(payload: .data(data: imageData))
        
        // 上传文件到 LeanCloud
        file.save { result in
            switch result {
            case .success:
                // 获取上传后的文件 URL
                if let fileURL = file.url?.value {
                    // 强制将 HTTP URL 替换为 HTTPS
                    let secureURL = fileURL.replacingOccurrences(of: "http://", with: "https://")
                    
                    // 查询用户并更新头像 URL
                    updateUserAvatar(objectId: objectId, avatarURL: secureURL) { success, message in
                        if success {
                            completion(true, "头像上传成功", secureURL)
                        } else {
                            completion(false, message, nil)
                        }
                    }
                } else {
                    completion(false, "获取文件 URL 失败", nil)
                }
                
            case .failure(let error):
                completion(false, "上传失败: \(error.localizedDescription)", nil)
            }
        }
    }
    
    
    // 更新用户头像 URL
    static func updateUserAvatar(objectId: String, avatarURL: String, completion: @escaping (Bool, String) -> Void) {
        let query = LCQuery(className: "_User")
        query.whereKey("objectId", .equalTo(objectId))
        
        query.find { result in
            switch result {
            case .success(let users):
                if let currentUser = users.first {
                    do {
                        try currentUser.set("avatarURL", value: avatarURL)
                        currentUser.save { saveResult in
                            switch saveResult {
                            case .success:
                                completion(true, "头像 URL 成功保存到用户表中")
                            case .failure(let error):
                                completion(false, "头像 URL 保存失败: \(error.localizedDescription)")
                            }
                        }
                    } catch {
                        completion(false, "更新头像 URL 失败: \(error.localizedDescription)")
                    }
                } else {
                    completion(false, "未找到当前用户")
                }
                
            case .failure(let error):
                completion(false, "查询用户失败: \(error.localizedDescription)")
            }
        }
    }
    
    
    // 根据兴趣标签从数据库获取活动
    static func fetchActivitiesByInterests(interests: [String], page: Int, pageSize: Int, completion: @escaping ([Activity]?, Int) -> Void) {
        let currentDate = Date()
        
        let query = LCQuery(className: "Activity")
        
        // 过滤兴趣标签匹配的活动
        query.whereKey("interestTag", .containedIn(interests))  // 查找兴趣标签包含在给定数组中的活动
        
        // 过滤活动时间晚于当前时间的活动
        query.whereKey("activityTime", .greaterThan(LCDate(currentDate))) // 活动时间必须在当前时间之后
        query.orderedKeys = "activityTime"
        // 设置分页参数
        query.limit = pageSize  // 每页数量
        query.skip = (page - 1) * pageSize  // 跳过前面的数据
        
        // 先查询总记录数
        let countQuery = LCQuery(className: "Activity")
        countQuery.whereKey("interestTag", .containedIn(interests))
        countQuery.whereKey("activityTime", .greaterThan(LCDate(currentDate)))
        
        countQuery.count { result in
            switch result {
            case .success(let totalCount):
                // 计算总页数
                let totalPages = Int(ceil(Double(totalCount) / Double(pageSize)))  // 总页数
                query.find { result in
                    switch result {
                    case .success(let objects):
                        // 将查询结果转化为 Activity 对象
                        let fetchedActivities = objects.compactMap { object -> Activity? in
                            guard let activityName = object["activityName"]?.stringValue,
                                  let interestTag = object["interestTag"]?.arrayValue,
                                  let activityTime = object["activityTime"]?.dateValue,
                                  let participantsCount = object["participantsCount"]?.intValue,
                                  let participantIds = object["participantIds"]?.arrayValue,
                                  let location = object["location"] as? LCGeoPoint
                            else {
                                return nil
                            }
                            
                            // 创建 Activity 对象
                            return Activity(
                                id: object.objectId!.stringValue ?? "",
                                activityName: activityName,
                                interestTag: interestTag as? Array<String> ?? [],
                                activityTime: activityTime,
                                activityDescription: "",
                                hostId: "",
                                hostUsername: "",
                                participantsCount: participantsCount,
                                participantIds: participantIds as? Array<String> ?? [],
                                location: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                                locationName: ""
                            )
                        }
                        
                        // 更新活动列表
                        DispatchQueue.main.async {
                            completion(fetchedActivities, totalPages)
                        }
                        
                    case .failure(let error):
                        // 错误处理
                        DispatchQueue.main.async {
                            print("查询失败: \(error.localizedDescription)")
                            completion(nil, 0)
                        }
                    }
                }
            case .failure(let error):
                // 错误处理
                DispatchQueue.main.async {
                    print("查询总数失败: \(error.localizedDescription)")
                    completion(nil, 0)
                }
            }
        }
    }
    
    
    // 加载所有活动数据（如果没有兴趣标签）
    static func fetchAllActivities(page: Int, pageSize: Int, completion: @escaping ([Activity]?, Int) -> Void) {
        let currentDate = Date()
        
        // 使用 LeanCloud SDK 查询所有活动
        let query = LCQuery(className: "Activity")
        
        // 过滤活动时间晚于当前时间的活动
        query.whereKey("activityTime", .greaterThan(LCDate(currentDate))) // 活动时间必须在当前时间之后
        query.orderedKeys = "activityTime"
        
        // 设置分页参数
        query.limit = pageSize  // 每页数量
        query.skip = (page - 1) * pageSize  // 跳过前面的数据
        
        // 先查询总记录数
        let countQuery = LCQuery(className: "Activity")
        countQuery.whereKey("activityTime", .greaterThan(LCDate(currentDate)))
        
        countQuery.count { result in
            switch result {
            case .success(let totalCount):
                // 计算总页数
                let totalPages = Int(ceil(Double(totalCount) / Double(pageSize)))  // 总页数
                query.find { result in
                    switch result {
                    case .success(let objects):
                        // 将查询结果转化为 Activity 对象
                        let fetchedActivities = objects.compactMap { object -> Activity? in
                            guard let activityName = object["activityName"]?.stringValue,
                                  let interestTag = object["interestTag"]?.arrayValue,
                                  let activityTime = object["activityTime"]?.dateValue,
                                  let participantsCount = object["participantsCount"]?.intValue,
                                  let participantIds = object["participantIds"]?.arrayValue,
                                  let location = object["location"] as? LCGeoPoint
                            else {
                                return nil
                            }
                            
                            // 创建 Activity 对象
                            return Activity(
                                id: object.objectId!.stringValue ?? "",
                                activityName: activityName,
                                interestTag: interestTag as? Array<String> ?? [],
                                activityTime: activityTime,
                                activityDescription: "",
                                hostId: "",
                                hostUsername: "",
                                participantsCount: participantsCount,
                                participantIds: participantIds as? Array<String> ?? [],
                                location: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                                locationName: ""
                            )
                        }
                        
                        // 更新活动列表
                        DispatchQueue.main.async {
                            completion(fetchedActivities, totalPages)
                        }
                        
                    case .failure(let error):
                        // 错误处理
                        DispatchQueue.main.async {
                            print("查询失败: \(error.localizedDescription)")
                            completion(nil, 0)
                        }
                    }
                }
            case .failure(let error):
                // 错误处理
                DispatchQueue.main.async {
                    print("查询总数失败: \(error.localizedDescription)")
                    completion(nil, 0)
                }
            }
        }
    }
    
    
    // 加载用户参与的活动
    static func fetchAllActivitiesIParticipatein(currentUserId: String, page: Int, pageSize: Int, completion: @escaping ([Activity]?, Int) -> Void) {
        let query = LCQuery(className: "Activity")
        
        // 过滤兴趣标签匹配的活动
        query.whereKey("participantIds", .containedIn([currentUserId]))
        query.orderedKeys = "-activityTime"
        
        // 设置分页参数
        query.limit = pageSize  // 每页数量
        query.skip = (page - 1) * pageSize  // 跳过前面的数据
        
        // 先查询总记录数
        let countQuery = LCQuery(className: "Activity")
        countQuery.whereKey("participantIds", .containedIn([currentUserId]))
        
        countQuery.count { result in
            switch result {
            case .success(let totalCount):
                // 计算总页数
                let totalPages = Int(ceil(Double(totalCount) / Double(pageSize)))  // 总页数
                query.find { result in
                    switch result {
                    case .success(let objects):
                        // 提取所有的 hostId
                        let hostIds = objects.compactMap { $0["hostId"]?.stringValue }
                        
                        // 查询所有 hostId 对应的用户名
                        let userQuery = LCQuery(className: "_User") // 假设 User 表名为 "_User"
                        userQuery.whereKey("objectId", .containedIn(hostIds))
                        userQuery.find { userResult in
                            switch userResult {
                            case .success(let userObjects):
                                // 创建一个字典，将 hostId 映射到 username
                                let hostIdToUsername = Dictionary(uniqueKeysWithValues: userObjects.compactMap { user -> (String, String)? in
                                    guard let userId = user.objectId?.stringValue,
                                          let username = user["username"]?.stringValue else {
                                        return nil
                                    }
                                    return (userId, username)
                                })
                                
                                // 将查询结果转化为 Activity 对象
                                let fetchedActivities = objects.compactMap { object -> Activity? in
                                    guard let activityName = object["activityName"]?.stringValue,
                                          let interestTag = object["interestTag"]?.arrayValue,
                                          let activityTime = object["activityTime"]?.dateValue,
                                          let activityDescription = object["activityDescription"]?.stringValue,
                                          let hostId = object["hostId"]?.stringValue,
                                          let participantsCount = object["participantsCount"]?.intValue,
                                          let participantIds = object["participantIds"]?.arrayValue,
                                          let location = object["location"] as? LCGeoPoint,
                                          let locationName = object["locationName"]?.stringValue
                                    else {
                                        return nil
                                    }
                                    
                                    let imageURLString = object["image"]?.stringValue ?? ""
                                    let image = imageURLString.isEmpty ? nil : URL(string: imageURLString)
                                    
                                    // 使用 hostId 从字典中查找 username
                                    let hostUsername = hostIdToUsername[hostId] ?? "未知用户"
                                    
                                    // 创建 Activity 对象
                                    return Activity(
                                        id: object.objectId!.stringValue ?? "",
                                        activityName: activityName,
                                        interestTag: interestTag as? Array<String> ?? [],
                                        activityTime: activityTime,
                                        activityDescription: activityDescription,
                                        hostId: hostId,
                                        hostUsername: hostUsername,
                                        participantsCount: participantsCount,
                                        participantIds: participantIds as? Array<String> ?? [],
                                        location: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                                        locationName: locationName,
                                        image: image
                                    )
                                }
                                
                                // 更新活动列表
                                DispatchQueue.main.async {
                                    completion(fetchedActivities, totalPages)
                                }
                                
                            case .failure(let error):
                                // 错误处理
                                DispatchQueue.main.async {
                                    print("查询用户失败: \(error.localizedDescription)")
                                    completion(nil, 0)
                                }
                            }
                        }
                    case .failure(let error):
                        // 错误处理
                        DispatchQueue.main.async {
                            print("查询活动失败: \(error.localizedDescription)")
                            completion(nil, 0)
                        }
                    }
                }
            case .failure(let error):
                // 错误处理
                DispatchQueue.main.async {
                    print("查询总数失败: \(error.localizedDescription)")
                    completion(nil, 0)
                }
            }
        }
    }
    
    
    
    // 获取活动详细信息
    static func fetchActivityDetails(activityId: String, completion: @escaping (Result<Activity, Error>) -> Void) {
        // LeanCloud 查询活动数据
        let query = LCQuery(className: "Activity")
        query.whereKey("objectId", .equalTo(activityId)) // 使用 LeanCloud 的 objectId 查找
        
        query.getFirst { result in
            switch result {
            case .success(let object):
                guard let activityName = object["activityName"]?.stringValue,
                      let interestTag = object["interestTag"]?.arrayValue,
                      let activityTime = object["activityTime"]?.dateValue,
                      let activityDescription = object["activityDescription"]?.stringValue,
                      let hostId = object["hostId"]?.stringValue,
                      let participantsCount = object["participantsCount"]?.intValue,
                      let participantIds = object["participantIds"]?.arrayValue,
                      let location = object["location"] as? LCGeoPoint,
                      let locationName = object["locationName"]?.stringValue
                else {
                    return
                }
                
                let imageURLString = object["image"]?.stringValue ?? ""
                // 如果 avatarURLString 有值，尝试转换为 URL
                let image = imageURLString.isEmpty ? nil : URL(string: imageURLString)
                
                // 获取 hostId 对应的用户（用户名）
                let userQuery = LCQuery(className: "_User")
                userQuery.whereKey("objectId", .equalTo(hostId))
                userQuery.getFirst { userResult in
                    switch userResult {
                    case .success(let userObject):
                        // 获取用户名
                        let username = userObject["username"]?.stringValue ?? "未知"
                        
                        // 创建活动模型对象
                        let activity = Activity(
                            id: object.objectId!.stringValue ?? "",
                            activityName: activityName,
                            interestTag: interestTag as? Array<String> ?? [],
                            activityTime: activityTime,
                            activityDescription: activityDescription,
                            hostId: hostId,
                            hostUsername: username,
                            participantsCount: participantsCount,
                            participantIds: participantIds as? Array<String> ?? [],
                            location: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                            locationName: locationName,
                            image: image  // 此处根据实际情况处理图片
                        )
                        completion(.success(activity))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    // 获取发起人信息
    static func fetchHostInfo(for userId: String, completion: @escaping (String, String, String, Int) -> Void) {
        let query = LCQuery(className: "_User")
        query.whereKey("objectId", .equalTo(userId))
        query.getFirst { result in
            switch result {
            case .success(let object):
                let username = object["username"]?.stringValue ?? "未知用户"
                let avatarURL = object["avatarURL"]?.stringValue ?? ""
                let gender = object["gender"]?.stringValue ?? ""
                let exp = object["exp"]?.intValue ?? 0
                completion(username, avatarURL, gender, exp)
            case .failure(let error):
                print("获取用户信息失败: \(error.localizedDescription)")
                completion("加载中...", "加载中...", "加载中...", 0) // 默认返回值
            }
        }
    }
    
    
    // 创建活动
    static func createActivity(activityName: String, selectedTags: [String], activityTime: Date, activityDescription: String, hostId: String?, location: CLLocationCoordinate2D?, locationName: String, selectedImage: UIImage?, participantsCount: Int, completion: @escaping (Bool, String) -> Void) {
        guard let hostId = hostId else {
            // 如果 hostId 为 nil，返回错误信息
            completion(false, "用户数据出错，请重新登录")
            return
        }
        
        // 检查数据是否有效
        if activityName.isEmpty {
            completion(false, "标题不能为空")
            return
        }
        
        // 检查时间是否合适
        if activityTime < Date() {
            completion(false, "时间不合适")
            return
        }
        
        // 检查简介是否有效
        if activityDescription.isEmpty {
            completion(false, "简介不能为空")
            return
        }
        
        let activity = LCObject(className: "Activity")
        activity["activityName"] = LCString(activityName)
        activity["interestTag"] = LCArray(selectedTags.map { LCString($0) })
        activity["activityTime"] = LCDate(activityTime)
        activity["activityDescription"] = LCString(activityDescription)
        activity["hostId"] = LCString(hostId)
        activity["participantsCount"] = LCNumber(integerLiteral: participantsCount)
        activity["participantIds"] = LCArray([hostId]) // 参与者 ID 数组（可以根据用户数据填充）
        activity["location"] = LCGeoPoint(latitude: location?.latitude ?? 39.90750000, longitude: location?.longitude ?? 116.38805555)
        activity["locationName"] = LCString(locationName)
        activity["isDone"] = LCBool(false)
        
        // 将 UIImage 转换为 JPEG 数据
        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            let file = LCFile(payload: .data(data: imageData))
            
            file.save { result in
                switch result {
                case .success:
                    // 获取文件的 URL 字符串
                    if let fileUrl = file.url?.value {
                        let secureURL = fileUrl.replacingOccurrences(of: "http://", with: "https://")
                        activity["image"] = LCString(secureURL) // 保存文件 URL 到 LeanCloud
                        saveActivity(activity: activity, hostId: hostId, completion: completion)  // 保存活动信息
                    } else {
                        completion(false, "图片上传失败，无法获取文件 URL")
                    }
                case .failure(let error):
                    completion(false, "图片上传失败: \(error.localizedDescription)")
                }
            }
        } else {
            // 如果没有选择图片，直接保存活动信息
            saveActivity(activity: activity, hostId: hostId, completion: completion)
        }
    }
    private static func saveActivity(activity: LCObject, hostId: String, completion: @escaping (Bool, String) -> Void) {
        let memberIds: Set<String> = Set([hostId])
        do {
            try IMClientManager.shared.getClient()?.createConversation(clientIDs: memberIds, attributes: ["isPrivate": false], isUnique: false) { result in
                switch result {
                case .success(let conversation):
                    print("Successfully created conversation!")
                    activity["groupChatId"] = LCString(conversation.ID)
                    // 群聊创建成功，继续保存活动信息
                    activity.save { result in
                        // 活动保存成功
                        completion(true, "活动发布成功！活动群聊可在群聊列表中查看！")
                    }
                case .failure(let error):
                    print("Failed to create conversation: \(error.localizedDescription)")
                    completion(false, "群聊创建失败，活动无法发布！")
                }
            }
        } catch {
            // 处理异常
            print("Error while trying to create conversation: \(error.localizedDescription)")
            completion(false, "群聊创建失败，活动无法发布！")
        }
    }
    
    
    // 获取私信列表
    static func fetchPrivateChats(completion: @escaping (Result<[PrivateChatList], Error>) -> Void) {
        guard let client = IMClientManager.shared.getClient() else {
            completion(.failure(NSError(domain: "IMClientError", code: 0, userInfo: [NSLocalizedDescriptionKey: "IMClient 未初始化"])))
            return
        }
        
        // 查询 _Conversation 表中包含当前用户的群聊
        let query = client.conversationQuery
        do {
            try query.where("unique", .equalTo(true))
            try query.where("attr", .equalTo(["isPrivate": true]))
            try query.where("m", .containedIn([IMClientManager.shared.getCurrentUserId() ?? "加载中..."]))
            try query.findConversations() { result in
                switch result {
                case .success(let conversations):
                    var privateChats: [PrivateChatList] = []
                    let totalConversations = conversations.count
                    var completedConversations = 0
                    
                    // 如果没有私信，直接返回空数组
                    if totalConversations == 0 {
                        completion(.success([]))
                        return
                    }
                    
                    for conversation in conversations {
                        let lmDate = conversation.updatedAt ?? Date() // 私信最后更新时间
                        if let clientIDs = conversation.members?.arrayValue as? [String] {
                            if let partnerId = clientIDs.first(where: { $0 != IMClientManager.shared.getCurrentUserId()}) {
                                LeanCloudService.fetchUserInfo(for: partnerId) { username, avatarURL, gender, exp in
                                    let chat = PrivateChatList(
                                        privateChatId: conversation.ID,
                                        partnerId: partnerId,
                                        partnerUsername: username,
                                        partnerAvatarURL: avatarURL,
                                        partnerGender: gender,
                                        partnerExp: exp,
                                        unreadMessagesCount: conversation.unreadMessageCount,
                                        lmDate: lmDate
                                    )
                                    privateChats.append(chat)
                                    // 返回结果
                                    if privateChats.count == conversations.count {
                                        completion(.success(privateChats))
                                    }
                                }
                            }
                        }
                        // 无论成功或失败，都增加完成计数
                        completedConversations += 1
                        if completedConversations == totalConversations {
                            completion(.success(privateChats)) // 所有会话处理完成后调用 completion
                        }
                    }
                case .failure(let error):
                    print("Error fetching conversations: \(error)")
                    completion(.failure(error))
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // 获取群聊列表
    static func fetchGroupChats(completion: @escaping (Result<[GroupChatList], Error>) -> Void) {
        // 通过 IMClientManager 获取客户端
        guard let client = IMClientManager.shared.getClient() else {
            completion(.failure(NSError(domain: "IMClientError", code: 0, userInfo: [NSLocalizedDescriptionKey: "IMClient 未初始化"])))
            return
        }
        
        // 查询 _Conversation 表中包含当前用户的群聊
        let query = client.conversationQuery
        do {
            try query.where("attr", .equalTo(["isPrivate": false]))
            try query.where("m", .containedIn([IMClientManager.shared.getCurrentUserId() ?? "加载中..."]))
            try query.findConversations { result in
                switch result {
                case .success(let conversations):
                    var groupChats: [GroupChatList] = []
                    let totalConversations = conversations.count
                    var completedConversations = 0
                    
                    // 如果没有群聊，直接返回空数组
                    if totalConversations == 0 {
                        completion(.success([]))
                        return
                    }
                    
                    for conversation in conversations {
                        let groupChatId = conversation.ID
                        
                        // 查询 Activity 表中对应的活动信息
                        let activityQuery = LCQuery(className: "Activity")
                        activityQuery.whereKey("groupChatId", .equalTo(groupChatId))
                        activityQuery.find { result in
                            switch result {
                            case .success(let activities):
                                for activity in activities {
                                    // 构造群聊对象
                                    let hostId = activity["hostId"]?.stringValue ?? ""
                                    let activityName = activity["activityName"]?.stringValue ?? "未知活动"
                                    let activityId = activity.objectId?.stringValue ?? "未知活动ID"
                                    let participantIds = conversation.members ?? [] // 获取群聊成员
                                    let lmDate = conversation.updatedAt ?? Date() // 群聊最后更新时间
                                    
                                    let groupChat = GroupChatList(
                                        groupChatId: groupChatId,
                                        hostId: hostId,
                                        activityId: activityId,
                                        participantIds: participantIds,
                                        activityName: activityName,
                                        unreadMessagesCount: conversation.unreadMessageCount,
                                        lmDate: lmDate
                                    )
                                    groupChats.append(groupChat)
                                }
                            case .failure(let error):
                                print("Error fetching activity: \(error)")
                            }
                            
                            // 无论成功或失败，都增加完成计数
                            completedConversations += 1
                            if completedConversations == totalConversations {
                                completion(.success(groupChats)) // 所有会话处理完成后调用 completion
                            }
                        }
                    }
                case .failure(let error):
                    print("Error fetching conversations: \(error)")
                    completion(.failure(error))
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // 获取私信对方的信息（头像和用户名）
    static func fetchUserInfo(for userId: String, completion: @escaping (String, String, String, Int) -> Void) {
        let query = LCQuery(className: "_User")
        query.whereKey("objectId", .equalTo(userId))
        query.getFirst { result in
            switch result {
            case .success(let object):
                let username = object["username"]?.stringValue ?? "未知用户"
                let avatarURL = object["avatarURL"]?.stringValue ?? ""
                let gender = object["gender"]?.stringValue ?? ""
                let exp = object["exp"]?.intValue ?? 0
                completion(username, avatarURL, gender, exp)
            case .failure(let error):
                print("获取用户信息失败: \(error.localizedDescription)")
                completion("未知用户", "", "", 0) // 默认返回值
            }
        }
    }
    
    
    // 获取本人创建的、还未开始的活动
    static func fetchFutureActivities(for currentUserId: String, completion: @escaping (Result<[String: [String]], Error>) -> Void) {
        // 获取当前时间
        let now = Date()
        
        // 查询 Activity 表
        let query = LCQuery(className: "Activity")
        query.whereKey("hostId", .equalTo(currentUserId))   // 查询 hostId 为当前用户的活动
        query.whereKey("activityTime", .greaterThan(now))   // 查询活动时间在当前时间之后的活动
        query.whereKey("isDone", .equalTo(true))
        // 执行查询
        query.find { result in
            switch result {
            case .success(let activities):
                var activityDict: [String: [String]] = [:]
                
                // 遍历查询到的活动，获取每个活动的 id 和 participantIds
                for activity in activities {
                    if let activityId = activity.objectId?.stringValue, // 获取活动的 id
                       let participants = activity["participantIds"]?.arrayValue as? [String] {
                        // 将活动 id 和参与者 id 添加到字典中
                        activityDict[activityId] = participants
                    }
                }
                
                // 返回字典
                completion(.success(activityDict))
                
            case .failure(let error):
                completion(.failure(error))  // 错误处理
            }
        }
    }
    
    
    // 获取活动数据
    static func fetchActivitiesFromDB(completion: @escaping ([HeatmapActivity]?, Error?) -> Void) {
        let query = LCQuery(className: "Activity")
        
        query.find { result in
            switch result {
            case .success(let objects):
                // 处理成功返回的数据，创建 HeatmapActivity 对象
                let fetchedHeatmapActivities = objects.compactMap { object -> HeatmapActivity? in
                    guard let interestTag = object["interestTag"]?.arrayValue,
                          let participantIds = object["participantIds"]?.arrayValue,
                          let location = object["location"] as? LCGeoPoint
                    else {
                        return nil
                    }
                    
                    return HeatmapActivity(
                        id: object.objectId!.stringValue ?? "",
                        location: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                        participatantCount: (participantIds as? Array<String> ?? []).count,
                        interestTag: interestTag as? Array<String> ?? []
                    )
                }
                // 调用 completion 闭包返回数据
                completion(fetchedHeatmapActivities, nil)
            case .failure(let error):
                // 调用 completion 闭包返回错误
                completion(nil, error)
            }
        }
    }
    
    
    // 用户参加活动
    static func addUserToConversationAndActivity(userId: String, activityId: String, completion: @escaping (Bool, String) -> Void) {
        let activityQuery = LCQuery(className: "Activity")
        activityQuery.whereKey("objectId", .equalTo(activityId))
        activityQuery.getFirst { result in
            switch result {
            case .success(let activity):
                // 查询 `_Conversation` 对象
                guard let groupChatId = activity["groupChatId"]?.stringValue else {
                    completion(false, "GroupChatId not found")
                    return
                }
                
                let conversationQuery = LCQuery(className: "_Conversation")
                conversationQuery.whereKey("objectId", .equalTo(groupChatId))
                conversationQuery.getFirst { result in
                    switch result {
                    case .success(let conversation):
                        // 添加用户到 "m" 字段
                        do {
                            try conversation.append("m", element: userId)
                            // 保存更新后的 `_Conversation` 对象
                            conversation.save { saveResult in
                                switch saveResult {
                                case .success:
                                    do {
                                        try activity.append("participantIds", element: userId)
                                        
                                        // 保存更新后的 `Activity` 对象
                                        activity.save { saveResult in
                                            switch saveResult {
                                            case .success:
                                                print("Successfully added user to Activity.participantIds")
                                                completion(true, "Successfully added user to both _Conversation and Activity.")
                                            case .failure(let error):
                                                print("Failed to update Activity: \(error.localizedDescription)")
                                                completion(false, "Failed to update Activity.")
                                            }
                                        }
                                    } catch {
                                        completion(false, "Failed to update Activity.")
                                    }
                                    print("Successfully added user to _Conversation.m")
                                case .failure(let error):
                                    print("Failed to update _Conversation: \(error)")
                                    completion(false, "Failed to update _Conversation.")
                                }
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    case .failure(let error):
                        print("Failed to query _Conversation: \(error.localizedDescription)")
                        completion(false, "Failed to find conversation.")
                    }
                }
            case .failure(let error):
                print("Failed to query Activity: \(error.localizedDescription)")
                completion(false, "Failed to find activity.")
            }
        }
    }
    
    
    // 活动发起者设置活动状态
    static func setActivityAsDone(userId: String, activityId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let query = LCQuery(className: "Activity")
        query.whereKey("hostId", .equalTo(userId))
        query.whereKey("objectId", .equalTo(activityId))
        
        query.getFirst { result in
            switch result {
            case .success(let activity):
                do {
                    try activity.set("isDone", value: true)
                    activity.save { saveResult in
                        switch saveResult {
                        case .success:
                            // 获取 participantIds
                            if let participantIds = activity.get("participantIds")?.arrayValue as? [String] {
                                let group = DispatchGroup() // 用于同步处理
                                var encounteredError: Error?
                                
                                for participantId in participantIds {
                                    group.enter()
                                    incrementExpForUser(userId: participantId) { result in
                                        if case .failure(let error) = result {
                                            encounteredError = error
                                        }
                                        group.leave()
                                    }
                                }
                                updateUserExp(userId: userId, expToDeduct: 1 - participantIds.count, completion: completion)
                                // 在所有任务完成后调用 completion
                                group.notify(queue: .main) {
                                    if let error = encounteredError {
                                        completion(.failure(error))
                                    } else {
                                        completion(.success(()))
                                    }
                                }
                            } else {
                                // 如果没有参与者，直接返回成功
                                completion(.success(()))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    // 为 _User 表中的参与者增加 exp
    static func incrementExpForUser(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: String] = [
            "userId": userId
        ]
        
        LCEngine.call("updateExp", parameters: parameters) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    // 获取活动状态
    static func fetchActivityStatus(activityId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let query = LCQuery(className: "Activity")
        query.whereKey("objectId", .equalTo(activityId))
        query.getFirst { result in
            switch result {
            case .success(let activity):
                let isDone = activity.get("isDone")?.boolValue ?? false
                completion(.success(isDone))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    // 完成用户退出群组与活动的操作
    static func exitGroupAndActivity(conversationId: String, userId: String, activityId: String, isDone: Bool,completion: @escaping (Result<Void, Error>) -> Void) {
        // Step 1: 从 _Conversation 表中移除用户
        let conversationQuery = LCQuery(className: "_Conversation")
        conversationQuery.whereKey("objectId", .equalTo(conversationId))
        conversationQuery.getFirst { conversationResult in
            switch conversationResult {
            case .success(let conversation):
                var members = conversation.get("m")?.arrayValue as? [String]
                if let index = members?.firstIndex(of: userId) {
                    members?.remove(at: index)
                    do {
                        try conversation.set("m", value: members)
                        conversation.save { saveResult in
                            switch saveResult {
                            case .success:
                                if !isDone {
                                    // Step 2: 从 Activity 表中移除用户
                                    removeUserFromActivity(activityId: activityId, userId: userId) { activityResult in
                                        switch activityResult {
                                        case .success:
                                            // Step 3: 扣减经验值（如果 Activity.isDone 为 false）
                                            deductUserExpIfRequired(activityId: activityId, userId: userId) { expResult in
                                                completion(expResult) // 成功或失败的结果传递回去
                                            }
                                        case .failure(let error):
                                            completion(.failure(error))
                                        }
                                    }
                                }
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(NSError(domain: "LeanCloudService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found in _Conversation"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    // 从 Activity 中移除用户
    private static func removeUserFromActivity(activityId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let query = LCQuery(className: "Activity")
        query.whereKey("objectId", .equalTo(activityId))
        query.getFirst { result in
            switch result {
            case .success(let activity):
                var participants = activity.get("participantIds")?.arrayValue as? [String]
                if let index = participants?.firstIndex(of: userId) {
                    participants?.remove(at: index)
                    do {
                        try activity.set("participantIds", value: participants)
                        activity.save { saveResult in
                            switch saveResult {
                            case .success:
                                completion(.success(()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(NSError(domain: "LeanCloudService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found in Activity"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    // 根据 isDone 判断是否扣减经验值
    private static func deductUserExpIfRequired(activityId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let query = LCQuery(className: "Activity")
        query.whereKey("objectId", .equalTo(activityId))
        query.getFirst { result in
            switch result {
            case .success(let activity):
                let isDone = activity.get("isDone")?.boolValue ?? false // 默认为 false
                let participantIds = activity.get("participantIds")?.arrayValue as? [String]
                if !isDone {
                    // 扣减经验值
                    updateUserExp(userId: userId, expToDeduct: participantIds?.count ?? 1, completion: completion)
                } else {
                    completion(.success(())) // 如果 isDone 为 true，直接返回成功
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    // 扣减用户经验值
    private static func updateUserExp(userId: String, expToDeduct: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let query = LCQuery(className: "_User")
        query.whereKey("objectId", .equalTo(userId))
        query.getFirst { result in
            switch result {
            case .success(let user):
                let currentExp = user.get("exp")?.intValue ?? 0
                do {
                    try user.set("exp", value: currentExp - expToDeduct)
                    user.save { saveResult in
                        switch saveResult {
                        case .success:
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    // 解散群聊/活动
    static func dismissGroup(activityId: String, conversationId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // 1. 查询 Activity 表
        let activityQuery = LCQuery(className: "Activity")
        activityQuery.whereKey("objectId", .equalTo(activityId))
        
        activityQuery.getFirst { result in
            switch result {
            case .success(let activity):
                // 2. 检查 isDone 字段
                let isDone = activity.get("isDone")?.boolValue ?? true
                let participantIds = activity.get("participantIds")?.arrayValue as? [String]
                let hostId = activity.get("hostId")?.stringValue ?? ""
                if !isDone {
                    activity.delete { deleteResult in
                        switch deleteResult {
                        case .success:
                            deleteConversation(conversationId: conversationId, completion: completion)
                            updateUserExp(userId: hostId, expToDeduct: participantIds?.count ?? 1, completion: completion)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    do {
                        // 删除 groupChatId 字段
                        try activity.set("groupChatId", value: nil)
                        activity.save { saveResult in
                            switch saveResult {
                            case .success:
                                deleteConversation(conversationId: conversationId, completion: completion)
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    // 解散群聊
    static func deleteConversation(conversationId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let conversationQuery = LCQuery(className: "_Conversation")
        conversationQuery.whereKey("objectId", .equalTo(conversationId))
        
        conversationQuery.getFirst { result in
            switch result {
            case .success(let conversation):
                conversation.delete { deleteResult in
                    switch deleteResult {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    // 踢出活动中的某个参与者
    static func removeParticipant(participantId: String, conversationId: String, activityId: String, completion: @escaping (Bool, Error?) -> Void) {
        let conversationQuery = LCQuery(className: "_Conversation")
        conversationQuery.whereKey("objectId", .equalTo(conversationId))
        
        conversationQuery.getFirst { result in
            switch result {
            case .success(let conversation):
                var participants = conversation.get("m")?.arrayValue as? [String] ?? []
                if let index = participants.firstIndex(of: participantId) {
                    participants.remove(at: index)
                } else {
                    completion(false, NSError(domain: "LeanCloudService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Participant not found in _Conversation"]))
                    return
                }
                do {
                    try conversation.set("m", value: participants)
                } catch {
                    completion(false, error)
                    return
                }
                
                conversation.save { conversationSaveResult in
                    switch conversationSaveResult {
                    case .success:
                        let activityQuery = LCQuery(className: "Activity")
                        activityQuery.whereKey("objectId", .equalTo(activityId))
                        
                        activityQuery.getFirst { activityResult in
                            switch activityResult {
                            case .success(let activity):
                                var participantIds = activity.get("participantIds")?.arrayValue as? [String] ?? []
                                if let index = participantIds.firstIndex(of: participantId) {
                                    participantIds.remove(at: index)
                                } else {
                                    completion(false, NSError(domain: "LeanCloudService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Participant not found in Activity"]))
                                    return
                                }
                                do {
                                    try activity.set("participantIds", value: participantIds)
                                } catch {
                                    completion(false, error)
                                    return
                                }
                                
                                activity.save { activitySaveResult in
                                    switch activitySaveResult {
                                    case .success:
                                        completion(true, nil)
                                    case .failure(let error):
                                        completion(false, error)
                                    }
                                }
                            case .failure(let error):
                                completion(false, error)
                            }
                        }
                    case .failure(let error):
                        completion(false, error)
                    }
                }
            case .failure(let error):
                completion(false, error)
            }
        }
    }
}
