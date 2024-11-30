//
//  PrivateChatListViewModel.swift
//  InterAct
//
//  Created by admin on 2024/11/30.
//

import Foundation
import LeanCloud
import UIKit

// 私聊会话模型
struct PrivateChat {
    let partnerId: String
    let partnerUsername: String
    let partnerAvatarURL: String
    let latestMessage: String
    let latestMessageTimestamp: Date
}

class PrivateChatListViewModel: ObservableObject {
    @Published var privateChats: [PrivateChat] = []   // 用于存储私聊列表
    @Published var errorMessage: String? = nil         // 错误消息绑定
    
    private var currentUserId: String = ""            // 当前用户ID
    
    init() {
        // 设置当前用户ID
        if let userId = UserDefaults.standard.string(forKey: "objectId") {
            self.currentUserId = userId
        }
    }
    
    // 获取与当前用户相关的私聊会话
    func fetchPrivateChats() {
        // 查询当前用户参与的私聊会话（包括自己作为创建者或接收者）
        let query = LCQuery(className: "IMConversation")
        query.whereKey("clientIDs", .contains(self.currentUserId))  // 确保查询包含当前用户
        query.includeKey("clientIDs")  // 包含clientIDs字段
        query.find { result in
            switch result {
            case .success(let conversations):
                // 如果获取到会话列表，遍历每个会话
                var chats: [PrivateChat] = []
                for conversation in conversations {
                    // 获取对方的ID（排除当前用户）
                    if let partnerId = conversation["clientIDs"]?.arrayValue?.first(where: { $0.stringValue != self.currentUserId })?.stringValue {
                        self.fetchUserInfo(for: partnerId) { username, avatarURL in
                            // 获取最新消息
                            self.fetchLatestMessage(for: conversation) { latestMessage, timestamp in
                                let chat = PrivateChat(
                                    partnerId: partnerId,
                                    partnerUsername: username,
                                    partnerAvatarURL: avatarURL,
                                    latestMessage: latestMessage,
                                    latestMessageTimestamp: timestamp
                                )
                                chats.append(chat)
                                DispatchQueue.main.async {
                                    self.privateChats = chats // 更新UI
                                }
                            }
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription // 错误处理
                }
            }
        }
    }
    
    // 获取用户信息（头像和用户名）
    private func fetchUserInfo(for userId: String, completion: @escaping (String, String) -> Void) {
        let query = LCQuery(className: "_User")
        query.whereKey("objectId", .equalTo(userId))
        query.getFirst { result in
            switch result {
            case .success(let object):
                // 获取用户名和头像URL
                let username = object["username"]?.stringValue ?? "未知用户"
                let avatarURL = object["avatarURL"]?.stringValue ?? "" // 可为空
                completion(username, avatarURL)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription // 错误处理
                }
            }
        }
    }
    
    // 获取私聊会话的最新消息
    private func fetchLatestMessage(for conversation: LCObject, completion: @escaping (String, Date) -> Void) {
        let messagesQuery = LCQuery(className: "IMMessage")
        messagesQuery.whereKey("conversation", .equalTo(conversation))
        messagesQuery.order(byDescending: "sentDate") // 按时间降序排序
        messagesQuery.limit = 1 // 只获取最新的一条消息
        messagesQuery.find { result in
            switch result {
            case .success(let messages):
                if let message = messages.first {
                    let messageText = message["text"]?.stringValue ?? "没有内容"
                    let timestamp = message["sentDate"]?.dateValue ?? Date()
                    completion(messageText, timestamp)
                } else {
                    completion("没有消息", Date()) // 如果没有消息
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription // 错误处理
                }
            }
        }
    }
}

