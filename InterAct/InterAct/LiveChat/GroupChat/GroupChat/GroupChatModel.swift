//
//  GroupChat.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import Foundation
import LeanCloud

struct GroupChat: Identifiable {
    var id: String
    var activityId: String
    var participants: [LCUser]
    var creator: LCUser
    
    init(id: String, activityId: String, creator: LCUser, participants: [LCUser] = []) {
        self.id = id
        self.activityId = activityId
        self.creator = creator
        self.participants = participants
    }
}

struct ParticipantInfo {
    let id: String
    var username: String
    var avatarURL: URL?
    var gender: String     
    var exp: Int
}
