//
//  GroupChat.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import Foundation

struct GroupChat: Identifiable {
    var id: String
    var chatId: String
    var participantIds: [String]
    var messages: [String]
}
