//
//  PrivateMessage.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import Foundation
import LeanCloud

struct Message: Identifiable {
    var id: String
    var senderId: String
    // var toId: String
    var content: String
    var timestamp: Date
}




struct User: Identifiable{
    let id: String          // 用户唯一标识符
    var username: String    // 用户名
    var avatarURL: URL?     // 用户头像 URL
    var email: String       // 用户邮箱
    var birthday: Date      // 用户生日
    var gender: String      // 用户性别
    var interest: Array<String> // 用户兴趣
}


