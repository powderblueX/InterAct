//
//  PrivateChatViewModel.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import Foundation
import LeanCloud
import UIKit

// TODO: 是否封装代码

class PrivateChatViewModel: ObservableObject {
    @Published var chat: PrivateChat? = PrivateChat(partnerId: "加载中...", partnerUsername: "加载中...", partnerAvatarURL: "")
    
    // 当前用户
    let currentUserId: String
    let recipientUserId: String
    
    // LeanCloud 客户端
    private var client: IMClient?
    private var conversation: IMConversation?
    
    // 数据绑定：通过这些闭包通知 View 层更新
    var onMessagesUpdated: (([Message]) -> Void)?
    @Published var onError: Error?
    
    // 当前消息列表
    @Published var messages: [Message] = [] {
        didSet {
            onMessagesUpdated?(messages)
        }
    }
    
    // 初始化
    init(currentUserId: String, recipientUserId: String) {
        self.currentUserId = currentUserId
        self.recipientUserId = recipientUserId
    }
    
    func fetchUserInfo(for userId: String) {
        // 调用 LeanCloudService 来获取用户信息（用户名和头像URL）
        LeanCloudService.fetchUserInfo(for: userId) { [weak self] username, avatarURL in
            // 更新 PrivateChat 实例
            if let chat = self?.chat {
                self?.chat = PrivateChat(
                    partnerId: chat.partnerId,
                    partnerUsername: username,
                    partnerAvatarURL: avatarURL
                )
            }
        }
    }
    
    // 打开聊天会话
    func openChatSession() {
        do {
            client = try IMClient(ID: currentUserId)
        } catch {
            print("Failed to initalize IMClient: \(error.localizedDescription)")
        }
        client?.open { [weak self] result in
            switch result {
            case .success:
                self?.fetchOrCreateConversation()
            case .failure(let error):
                self?.onError = error
            }
        }
    }
    
    // 查找或创建一个私信对话
    private func fetchOrCreateConversation() {
        do {
            try client?.createConversation(clientIDs: [recipientUserId], isUnique: true) { [weak self] result in
                switch result {
                case .success(let conversation):
                    self?.conversation = conversation
                    self?.setupMessageReceiving()
                    self?.loadMessageHistory()
                case .failure(let error):
                    self?.onError = error
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // 监听消息接收
    private func setupMessageReceiving() {
        client?.delegate = self
    }
    
    // 加载历史消息
    private func loadMessageHistory() {
        do {
            try conversation?.queryMessage{ [weak self] result in
                switch result {
                case .success(let messages):
                    self?.messages = messages.compactMap { message in
                        if let textMessage = message as? IMTextMessage {
                            return Message(
                                id: message.ID ?? UUID().uuidString,
                                senderId: textMessage.fromClientID ?? "unknown",
                                content: textMessage.text ?? "",
                                timestamp: textMessage.sentDate ?? Date()
                            )
                        }
                        return nil
                    }
                case .failure(let error):
                    self?.onError = error
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // 发送消息
    func sendMessage(_ text: String) {
        guard let conversation = conversation else { return }
        
        let message = IMTextMessage(text: text)
        do {
            try conversation.send(message: message) { [weak self] result in
                switch result {
                case .success:
                    let newMessage = Message(
                        id: message.ID ?? UUID().uuidString,
                        senderId: self?.currentUserId ?? "unknown",
                        content: text,
                        timestamp: message.sentDate ?? Date()
                    )
                    self?.messages.append(newMessage)
                case .failure(let error):
                    self?.onError = error
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // TODO: 选择图片
    func selectImage() {
        
    }
    
    // 发送图片消息
    func sendImage(_ image: UIImage) {
        guard conversation != nil else { return }
        
        // 将图片转换为 LeanCloud 支持的格式（比如：保存到 LeanCloud 或发送为图片消息）
        // TODO: 这里省略了上传图片的具体实现，假设我们可以生成一个图片消息
//        let imageMessage = IMImageMessage(image: image)
//        
//        do {
//            try conversation.send(message: imageMessage) { [weak self] result in
//                switch result {
//                case .success:
//                    let newMessage = Message(
//                        id: imageMessage.ID ?? UUID().uuidString,
//                        senderId: self?.currentUserId ?? "unknown",
//                        content: "图片消息",
//                        timestamp: imageMessage.sentDate ?? Date()
//                    )
//                    self?.messages.append(newMessage)
//                case .failure(let error):
//                    self?.onError?(error)
//                }
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
    }
}

extension PrivateChatViewModel: IMClientDelegate {
    func client(_ client: IMClient, conversation: IMConversation, event: IMConversationEvent) {
        // 处理对话事件
    }
    
    func client(_ client: IMClient, event: IMClientEvent) {
        // 处理客户端事件
    }
    
    // 收到新消息
    func client(_ client: IMClient, conversation: IMConversation, didReceive message: IMMessage) {
        if let textMessage = message as? IMTextMessage {
            let newMessage = Message(
                id: message.ID ?? UUID().uuidString,
                senderId: textMessage.fromClientID ?? "unknown",
                content: textMessage.text ?? "",
                timestamp: textMessage.sentDate ?? Date()
            )
            self.messages.append(newMessage)
        }
    }
}


