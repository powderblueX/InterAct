//
//  GroupChatModel.swift
//  InterAct
//
//  Created by admin on 2024/12/6.
//

import Foundation
import LeanCloud

struct GroupChatList{
    let groupChatId: String
    let activityId: String
    let participantIds: [String]
    let activityName: String
    var unreadMessagesCount: Int?
    var conversation: IMConversation?
    let lmDate: Date   
}
