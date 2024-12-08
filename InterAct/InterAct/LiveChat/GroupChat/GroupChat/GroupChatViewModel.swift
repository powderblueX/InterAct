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
    @Published var groupChatId: String // TODO: 修改
    @Published var currentUserId: String?
    @Published var participants: [LCUser] = [] // 存储群聊参与者
    
    @Published var onError: Error?
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    @Published var participantsInfo: [ParticipantInfo]? = nil
    
    // 数据绑定：通过这些闭包通知 View 层更新
    var onMessagesUpdated: (([Message]) -> Void)?
    // 当前消息列表
    @Published var messages: [Message] = [] {
        didSet {
            self.onMessagesUpdated?(messages)
        }
    }

    private var conversation: IMConversation?
    
    init(conversationID: String) {
        self.groupChatId = conversationID
        subscribeToMessages()
        currentUserId = imClientManager.getCurrentUserId()
    }
    private func subscribeToMessages() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMessage(_:)), name: .newMessageReceived, object: nil)
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
    
//    func initializeIMClient(completion: @escaping (Bool) -> Void) {
//        // 从 UserDefaults 获取当前用户的 ID
//        guard let userId = UserDefaults.standard.string(forKey: "objectId") else {
//            self.isLoading = false
//            self.alertMessage = "当前用户ID不可用"
//            completion(false) // 返回失败并给出错误消息
//            return
//        }
//        currentUserId = userId
//        do {
//            // 初始化 IMClient 实例
//            self.client = try IMClient(ID: userId)
//            print("IMClient initialized successfully with ID: \(userId)") // 调试日志
//        } catch {
//            print("Failed to initialize IMClient: \(error.localizedDescription)") // 打印错误
//            self.isLoading = false
//            self.alertMessage = "初始化 IMClient 失败: \(error.localizedDescription)"
//            completion(false) // 返回失败
//            return
//        }
//        
//        // 设置消息接收处理
//        self.setupMessageReceiving()
//        
//        // 打开 IMClient 连接
//        self.client?.open { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success:
//                print("IMClient connected successfully") // 调试日志
//                self.isLoading = false
//                completion(true) // 返回成功
//            case .failure(let error):
//                print("Failed to open IMClient connection: \(error.localizedDescription)") // 打印错误
//                self.isLoading = false
//                self.alertMessage = "打开 IMClient 连接失败: \(error.localizedDescription)"
//                completion(false) // 返回失败
//            }
//        }
//    }
    private var imClientManager = IMClientManager.shared
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
    
    // 加载历史消息
    private func loadMessageHistory() {
        do {
            if let conversation = conversation {
                print("Conversation ID: \(conversation.ID)")
                print("Conversation Members: \(String(describing: conversation.members))")
            } else {
                print("Conversation is nil")
            }

            try conversation?.queryMessage{ [weak self] result in
                switch result {
                case .success(let messages):
                    self?.conversation?.read()
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

extension GroupChatViewModel: IMClientDelegate {
    func client(_ client: LeanCloud.IMClient, conversation: LeanCloud.IMConversation, event: LeanCloud.IMConversationEvent) {
        switch event {
        case .message(let messageEvent):
            switch messageEvent {
            case .received(let message):
                // 处理接收到的消息
                if let textMessage = message as? IMTextMessage {
                    // 如果消息是文本类型，则将其转换为自定义的 Message 模型
                    let newMessage = Message(
                        id: message.ID ?? UUID().uuidString,
                        senderId: textMessage.fromClientID ?? "unknown",
                        content: textMessage.text ?? "",
                        timestamp: textMessage.sentDate ?? Date()
                    )
                    // 将新消息添加到 messages 数组中
                    self.messages.append(newMessage)
                    // 如果你需要更新 UI 或进行其他操作，可以在这里调用相应方法
                    print("New message received: \(newMessage.content)")
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    func client(_ client: IMClient, event: IMClientEvent) {
        print("Received event: \(event)") // 打印事件类型
        switch event {
        case .sessionDidClose(let error):
            print("Session closed with error: \(error.localizedDescription)")
        case .sessionDidOpen:
            print("Session opened successfully.")
        case .sessionDidPause(let error):
            print("Session paused with error: \(error.localizedDescription)")
        case .sessionDidResume:
            print("Session resumed successfully.")
        }
    }
}
