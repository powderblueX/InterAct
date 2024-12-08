//
//  PrivateChatListModel.swift
//  InterAct
//
//  Created by admin on 2024/12/1.
//

import Foundation
import LeanCloud

// 私聊会话模型
struct PrivateChatList {
    let privateChatId: String
    let partnerId: String
    let partnerUsername: String
    let partnerAvatarURL: String
    let partnerGender: String
    let partnerExp: Int
    let unreadMessagesCount: Int
    let lmDate: Date
}


