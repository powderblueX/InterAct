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
// TODO: 实现退出页面后断开连接

class PrivateChatViewModel: ObservableObject {
    @Published var activityDict: [String: [String]]? = nil
    @Published var partner: Partner? = nil
    @Published var currentUserId: String?
    @Published var privateChatId: String
    var sendParticipateIn: SendParticipateIn? = nil
    private var imClientManager = IMClientManager.shared
    private var conversation: IMConversation?
    @Published var isLoading: Bool = false
    @Published var hasMoreMessages: Bool = true
    private var lastMessage: IMMessage? // 记录最后一条消息，用于分页加载
    
    // 数据绑定：通过这些闭包通知 View 层更新
    var onMessagesUpdated: (([Message]) -> Void)?
    // 当前消息列表
    @Published var messages: [Message] = [] {
        didSet {
            self.onMessagesUpdated?(messages)
        }
    }
    
    @Published var onError: Error?
    
    func updatePrivateChat(){
        activityDict = nil
        messages = []
        hasMoreMessages = true
        loadRecentMessages()
    }
    
    // 初始化
    init(privateChatId: String, sendParticipateIn: SendParticipateIn? = nil) {
        currentUserId = imClientManager.getCurrentUserId()
        self.privateChatId = privateChatId
        self.sendParticipateIn = sendParticipateIn
        subscribeToMessages()
    }
    private func subscribeToMessages() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMessage(_:)), name: .newMessagePrivateChatReceived, object: nil)
    }
    @objc private func handleNewMessage(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let receivedConversationID = userInfo["conversationID"] as? String,
              receivedConversationID == privateChatId, // 确保是当前会话的消息
              let message = userInfo["message"] as? IMTextMessage else { return }
        
        // 如果消息是文本类型，则将其转换为自定义的 Message 模型
        var newMessage = Message(
            id: message.ID ?? UUID().uuidString,
            senderId: message.fromClientID ?? "unknown",
            content: message.text ?? "",
            timestamp: message.sentDate ?? Date()
        )
        if newMessage.content.starts(with: "# wannaParticipateIn: ") {
            let activityJSONString = String(newMessage.content.dropFirst("# wannaParticipateIn: ".count)) // 去掉前缀
            if let activity = decodeJSONStringToActivity(jsonString: activityJSONString) {
                newMessage.content = "我想参加您发起的活动：”"+activity.activityName+"“"
                self.messages.append(newMessage)
            }
        } else {
            // 将新消息添加到 messages 数组中
            self.messages.append(newMessage)
        }
        // 如果你需要更新 UI 或进行其他操作，可以在这里调用相应方法
        print("New message received: \(newMessage.content)")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func fetchMyFutureActivity() {
        if let currentUserId = self.currentUserId {
            LeanCloudService.fetchFutureActivities(for: currentUserId) { result in
                switch result {
                case .success(let activityDict):
                    self.activityDict = activityDict
                    print(activityDict)
                case .failure(let error):
                    print("Failed to fetch activities: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchUserInfo(for userId: String) {
        LeanCloudService.fetchUserInfo(for: userId) { [weak self] username, avatarURL, gender, exp in
            self?.partner = Partner(
                id: userId,
                username: username,
                avatarURL: URL(string: avatarURL),
                gender: gender,
                exp: exp)
        }
    }
    
    // 查找一个私信对话
    func fetchConversation() {
        do {
            try imClientManager.getClient()?.conversationQuery.getConversation(by: privateChatId) { result in
                switch result {
                case .success(let conversation):
                    self.conversation = conversation
                    self.privateChatId = conversation.ID
                    self.loadRecentMessages()
                case .failure(let error):
                    self.onError = error
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // 创建一个私信对话
    func createConversation(to recipientUserId: String) {
        do {
            try imClientManager.getClient()?.createConversation(clientIDs: [recipientUserId], attributes: ["isPrivate": true] ,isUnique: true) { [weak self] result in
                switch result {
                case .success(let conversation):
                    self?.conversation = conversation
                    print("Conversation created: \(conversation)")
                    self?.privateChatId = conversation.ID
                    self?.loadRecentMessages()
                case .failure(let error):
                    self?.onError = error
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func readMessages(){
        self.conversation?.read()
    }
    
    // 加载最新的消息（首次或刷新）
    func loadRecentMessages() {
        guard let conversation = conversation else { return }
        isLoading = true
        if let sendParticipateIn = self.sendParticipateIn {
            // 假设你在发送消息时，将封装后的Activity JSON字符串作为消息的内容
            if let activityJSONString = self.encodeActivityToJSONString(sendParticipateIn: sendParticipateIn) {
                let messageContent = activityJSONString
                self.sendMessage("# wannaParticipateIn: " + messageContent)  // 调用发送消息的函数
            }
            self.sendParticipateIn = nil
        }
        
        do {
            readMessages()
            try conversation.queryMessage(limit: 20) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let messages):
                        self?.messages = messages.compactMap { self?.convertToMessage($0) }
                        self?.lastMessage = messages.first
                        self?.hasMoreMessages = messages.count == 20 // 如果少于 20 条，说明没有更多消息
                    case .failure(let error):
                        print("加载消息失败：\(error)")
                    }
                }
            }
        } catch {
            print("加载消息异常：\(error.localizedDescription)")
            isLoading = false
        }
    }
    
    // 分页加载历史消息
    func loadMoreMessages() {
        guard let conversation = conversation, hasMoreMessages, !isLoading else { return }
        isLoading = true
        
        do {
            readMessages()
            let startPoint: IMConversation.MessageQueryEndpoint?
            if let lastMessage = lastMessage {
                startPoint = IMConversation.MessageQueryEndpoint(
                    messageID: lastMessage.ID,
                    sentTimestamp: lastMessage.sentDate?.timeIntervalSince1970 != nil ? Int64(lastMessage.sentDate!.timeIntervalSince1970 * 1000) : nil,
                    isClosed: false
                )
            } else {
                startPoint = nil
            }
            
            try conversation.queryMessage(start: startPoint, limit: 20) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let messages):
                        let newMessages = messages.compactMap { self?.convertToMessage($0) }
                        self?.messages.insert(contentsOf: newMessages, at: 0)
                        self?.lastMessage = messages.first
                        self?.hasMoreMessages = messages.count == 20
                    case .failure(let error):
                        print("加载历史消息失败：\(error)")
                    }
                }
            }
        } catch {
            print("加载历史消息异常：\(error.localizedDescription)")
            isLoading = false
        }
    }
    
    // 消息模型转换
    private func convertToMessage(_ message: IMMessage) -> Message? {
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
    
    // 发送消息
    func sendMessage(_ text: String) {
        guard let conversation = conversation else { return }
        
        let message = IMTextMessage(text: text)
        do {
            try conversation.send(message: message) { [weak self] result in
                switch result {
                case .success:
                    var text_temp = text
                    if text.starts(with: "# wannaParticipateIn: ") {
                        let activityJSONString = String(text.dropFirst("# wannaParticipateIn: ".count)) // 去掉前缀
                        if let activity = self?.decodeJSONStringToActivity(jsonString: activityJSONString) {
                            text_temp = "我想参加您发起的活动：”"+activity.activityName+"“"
                        }
                    }
                    let newMessage = Message(
                        id: message.ID ?? UUID().uuidString,
                        senderId: self?.currentUserId ?? "unknown",
                        content: text_temp,
                        timestamp: message.sentDate ?? Date()
                    )
                    DispatchQueue.main.async {
                        self?.messages.append(newMessage)
                    }
                case .failure(let error):
                    print("Failed to send message: \(error.localizedDescription)")
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
        

        // TODO: 这里省略了上传图片的具体实现，假设我们可以生成一个图片消息

    }
    
    // 编码Activity为JSON字符串
    func encodeActivityToJSONString(sendParticipateIn: SendParticipateIn) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // 可选：格式化输出
        
        do {
            let data = try encoder.encode(sendParticipateIn)  // 编码为Data
            if let jsonString = String(data: data, encoding: .utf8) { // 转换为JSON字符串
                return jsonString
            }
        } catch {
            print("Error encoding activity to JSON: \(error)")
        }
        return nil
    }
    
    func decodeJSONStringToActivity(jsonString: String) -> SendParticipateIn? {
        let decoder = JSONDecoder()
        
        if let data = jsonString.data(using: .utf8) {
            do {
                let activity = try decoder.decode(SendParticipateIn.self, from: data)
                return activity
            } catch {
                print("Error decoding JSON to activity: \(error)")
            }
        }
        return nil
    }
    
}

//// 加载历史消息
//private func loadMessageHistory() {
//    if let sendParticipateIn = self.sendParticipateIn {
//        // 假设你在发送消息时，将封装后的Activity JSON字符串作为消息的内容
//        if let activityJSONString = self.encodeActivityToJSONString(sendParticipateIn: sendParticipateIn) {
//            let messageContent = activityJSONString
//            self.sendMessage("# wannaParticipateIn: " + messageContent)  // 调用发送消息的函数
//        }
//    }
//    do {
//        readMessages()
//        
//        try conversation?.queryMessage(limit: 20){ [weak self] result in
//            switch result {
//            case .success(let messages):
//                self?.messages = messages.compactMap { message in
//                    if let textMessage = message as? IMTextMessage {
//                        return Message(
//                            id: message.ID ?? UUID().uuidString,
//                            senderId: textMessage.fromClientID ?? "unknown",
//                            content: textMessage.text ?? "",
//                            timestamp: textMessage.sentDate ?? Date()
//                        )
//                    }
//                    return nil
//                }
//            case .failure(let error):
//                self?.onError = error
//            }
//        }
//
//    } catch {
//        print(error.localizedDescription)
//    }
//}
