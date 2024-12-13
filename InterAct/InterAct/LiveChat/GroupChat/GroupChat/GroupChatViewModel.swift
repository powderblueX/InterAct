//
//  GroupChatViewModel.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import Foundation
import LeanCloud

class GroupChatViewModel: ObservableObject {
    @Published var groupChatId: String
    @Published var currentUserId: String?
    @Published var participants: [LCUser] = [] // 存储群聊参与者
    
    @Published var onError: Error?
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    @Published var isLoading: Bool = false
    @Published var hasMoreMessages: Bool = true
    private var lastMessage: IMMessage? // 记录最后一条消息，用于分页加载
    private var conversation: IMConversation?
    private var imClientManager = IMClientManager.shared
    @Published var participantsInfo: [ParticipantInfo]? = nil
    var onMessagesUpdated: (([Message]) -> Void)?
    // 当前消息列表
    @Published var messages: [Message] = [] {
        didSet {
            self.onMessagesUpdated?(messages)
        }
    }
    
    init(conversationID: String) {
        self.groupChatId = conversationID
        subscribeToMessages()
        currentUserId = imClientManager.getCurrentUserId()
    }
    private func subscribeToMessages() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMessage(_:)), name: .newMessageGroupChatReceived, object: nil)
    }
    @objc private func handleNewMessage(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let receivedConversationID = userInfo["conversationID"] as? String,
              receivedConversationID == groupChatId, // 确保是当前会话的消息
              let message = userInfo["message"] as? IMTextMessage else { return }
        
        let newMessage = Message(
            id: message.ID ?? UUID().uuidString,
            senderId: message.fromClientID ?? "unknown",
            content: message.text ?? "",
            timestamp: message.sentDate ?? Date()
        )
        
        DispatchQueue.main.async {
            self.messages.append(newMessage)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func fetchAllparticipantsInfo(ParticipantIds: [String]) {
        var fetchedParticipants: [ParticipantInfo] = []
        let dispatchGroup = DispatchGroup() // 用于同步多个异步任务
        
        for userId in ParticipantIds {
            dispatchGroup.enter()
            LeanCloudService.fetchHostInfo(for: userId) { username, avatarURL, gender, exp in
                let participant = ParticipantInfo(
                    id: userId,
                    username: username,
                    avatarURL: URL(string: avatarURL),
                    gender: gender,
                    exp: exp
                )
                fetchedParticipants.append(participant)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            // 所有异步任务完成后更新 `participantsInfo`
            self.participantsInfo = fetchedParticipants
        }
    }
    
    func joinGroupChat(with chat: GroupChatList) {
        do {
            try imClientManager.getClient()?.conversationQuery.getConversation(by: chat.groupChatId) { result in
                switch result {
                case .success(let createdConversation):
                    self.conversation = createdConversation
                    print("Successfully joined conversation \(String(describing: self.conversation))")
                    self.loadRecentMessages()
                case .failure(let error):
                    print("Failed to joined conversation: \(error)")
                }
            }
        } catch {
            print("Failed to joined conversation: \(error)")
        }
    }
    
    func readMessages(){
        self.conversation?.read()
    }
    
    // 加载最新的消息（首次或刷新）
    func loadRecentMessages() {
        guard let conversation = conversation else { return }
        isLoading = true
        
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
}
