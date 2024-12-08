//
//  GroupChatViewModel.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import Foundation
import LeanCloud

class GroupChatViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var groupChatId: String
    @Published var currentUserId: String?
    @Published var participants: [LCUser] = [] // 存储群聊参与者
    
    @Published var onError: Error?
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
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
                    print("Successfully created conversation \(String(describing: self.conversation))")
                    self.loadMessageHistory()
                case .failure(let error):
                    print("Failed to create conversation: \(error)")
                }
            }
        } catch {
            print("Failed to create conversation: \(error)")
        }
    }
    
    func readMessages(){
        self.conversation?.read()
    }
    
    // 加载历史消息
    private func loadMessageHistory() {
        do {
            if let conversation = conversation {
                print("Conversation ID: \(conversation.ID)")
                print("Conversation Members: \(String(describing: conversation.members))")
            } else {
                print("Conversation is nil")
            }
            readMessages()
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
        } catch let error {
            print("Error caught in catch block: \(error.localizedDescription)")
        }
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
