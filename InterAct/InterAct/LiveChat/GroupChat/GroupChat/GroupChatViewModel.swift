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
    @Published var groupChatId: String? = "" // TODO: 修改
    @Published var currentUserId: String?
    @Published var participants: [LCUser] = [] // 存储群聊参与者
    
    @Published var onError: Error?
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    @Published var participantsInfo: [ParticipantInfo]? = nil
    
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
    
    // 数据绑定：通过这些闭包通知 View 层更新
    var onMessagesUpdated: (([Message]) -> Void)?
    // 当前消息列表
    @Published var messages: [Message] = [] {
        didSet {
            self.onMessagesUpdated?(messages)
        }
    }
    
    // 存储IMClient实例
    private var client: IMClient?
    private var conversation: IMConversation?
    
    func initializeIMClient(completion: @escaping (Bool) -> Void) {
        // 从 UserDefaults 获取当前用户的 ID
        guard let userId = UserDefaults.standard.string(forKey: "objectId") else {
            self.isLoading = false
            self.alertMessage = "当前用户ID不可用"
            completion(false) // 返回失败并给出错误消息
            return
        }
        currentUserId = userId
        do {
            // 初始化 IMClient 实例
            self.client = try IMClient(ID: userId)
            print("IMClient initialized successfully with ID: \(userId)") // 调试日志
        } catch {
            print("Failed to initialize IMClient: \(error.localizedDescription)") // 打印错误
            self.isLoading = false
            self.alertMessage = "初始化 IMClient 失败: \(error.localizedDescription)"
            completion(false) // 返回失败
            return
        }
        
        // 设置消息接收处理
        self.setupMessageReceiving()
        
        // 打开 IMClient 连接
        self.client?.open { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                print("IMClient connected successfully") // 调试日志
                self.isLoading = false
                completion(true) // 返回成功
            case .failure(let error):
                print("Failed to open IMClient connection: \(error.localizedDescription)") // 打印错误
                self.isLoading = false
                self.alertMessage = "打开 IMClient 连接失败: \(error.localizedDescription)"
                completion(false) // 返回失败
            }
        }
    }
    
    func joinGroupChat(with chat: GroupChatList) {
        do {
            try client?.conversationQuery.getConversation(by: chat.groupChatId) { result in
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
    
    
    func createOrJoinGroupChat(activityId: String, user: LCUser, participants: [LCUser], completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        
        // 查询活动参与者
        fetchParticipants(forActivityId: activityId) { participants in
            // 获取参与者后，创建群聊
            self.createGroupChat(activityId: activityId, participants: participants) { success, errorMessage in
                // 返回群聊创建或加入的结果
                completion(success, errorMessage)
                self.isLoading = false
            }
        }
    }


    
    // 2. 查询活动的参与者
    func fetchParticipants(forActivityId activityId: String, completion: @escaping ([LCUser]) -> Void) {
        currentUserId = UserDefaults.standard.string(forKey: "objectId")
        // 查询 Activity 表，获取该活动的参与者对象 ID 列表
        let activityQuery = LCQuery(className: "Activity")
        activityQuery.whereKey("objectId", .equalTo(activityId))
        activityQuery.find { result in
            switch result {
            case .success(let objects):
                guard let activityObject = objects.first else {
                    self.isLoading = false
                    return
                }
                
                // 获取参与者的 ID 列表
                if let participantIds = activityObject.participantIds?.arrayValue as? [String] {
                    // 根据参与者的 ID 查询对应的 User 对象
                    self.fetchUsers(byObjectIds: participantIds, completion: completion)
                } else {
                    print("查询活动失败")
                    self.isLoading = false
                }
            case .failure(let error):
                print("查询活动失败: \(error)")
                self.isLoading = false
            }
        }
    }
    
    // 3. 根据 User 表的 objectId 查询用户信息
    func fetchUsers(byObjectIds objectIds: [String], completion: @escaping ([LCUser]) -> Void) {
        let userQuery = LCQuery(className: "_User")  // _User 表是 LeanCloud 默认的用户表
        userQuery.whereKey("objectId", .containedIn(objectIds))  // 查询所有 objectId 在给定数组中的用户
        
        userQuery.find { result in
            switch result {
            case .success(let objects):
                let participants: [LCUser] = objects.compactMap { object in
                    // 将查询到的对象转化为 LCUser 类型
                    object as? LCUser
                }
                completion(participants)
            case .failure(let error):
                print("查询用户失败: \(error)")
                self.isLoading = false
            }
        }
    }
    
    // 2. 创建群聊
    private func createGroupChat(activityId: String, participants: [LCUser], completion: @escaping (Bool, String?) -> Void) {
        // 使用IMClient.sharedInstance初始化
        guard let userId = UserDefaults.standard.string(forKey: "objectId") else {
            self.isLoading = false
            completion(false, "当前用户ID不可用")  // 返回失败并给出错误消息
            return
        }
        
        do {
            try client = IMClient(ID: userId)
            print("IMClient initialized successfully with ID: \(userId)")  // 调试日志
        } catch {
            print("Failed to initalize IMClient: \(error.localizedDescription)")
            self.isLoading = false
            completion(false, "初始化IMClient失败")  // 返回失败并给出错误消息
            return
        }
        
        self.setupMessageReceiving()
        
        client?.open { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.createGroup(activityId: activityId, participants: participants, completion: { success, errorMessage in
                    if success {
                        completion(true, nil)  // 群聊创建成功，返回成功
                    } else {
                        completion(false, errorMessage)  // 群聊创建失败，返回失败和错误消息
                    }
                })
            case .failure(let error):
                print("Failed to open client: \(error)")
                self.isLoading = false
                completion(false, "客户端打开失败: \(error.localizedDescription)")  // 返回失败并给出错误消息
            }
        }
    }
    
    // 监听消息接收
    private func setupMessageReceiving() {
        print("Setting up delegate for message receiving.")  // 调试日志
        client?.delegate = self
    }
    
    // 3. 创建群聊并加入成员
    private func createGroup(activityId: String, participants: [LCUser], completion: @escaping (Bool, String?) -> Void) {
        
        // 使用 LeanCloud 提供的群聊功能创建群组
        let memberIds: Set<String> = Set(participants.map { $0.objectId?.value ?? "" })
        
        do {
            // 调用创建群聊的方法
            try client?.createConversation(clientIDs: memberIds, isUnique: true) { [weak self] result in
                switch result {
                case .success(let createdGroup):
                    print("Successfully created group with ID: \(createdGroup.ID)")
                    self?.conversation = createdGroup  // 存储会话对象
                    self?.groupChatId = createdGroup.ID
                    self?.isLoading = false
                    self?.loadMessageHistory()
                    // 返回群聊创建成功
                    completion(true, nil)
                case .failure(let error):
                    print("Failed to create group: \(error)")
                    self?.isLoading = false
                    
                    // 返回群聊创建失败，并提供错误信息
                    completion(false, error.localizedDescription)
                }
            }
        } catch {
            completion(false, error.localizedDescription)
        }
    }
    
    

    // 发送消息
    func sendMessageToGroup(message: IMMessage) {
        guard let conversation = conversation else {
            print("No conversation available")
            return
        }
        do {
            try conversation.send(message: message) { result in
                switch result {
                case .success:
                    let newMessage = Message(
                        id: message.ID ?? UUID().uuidString,
                        senderId: self.currentUserId ?? "unknown",
                        content: message.content?.string ?? "",
                        timestamp: message.sentDate ?? Date()
                    )
                    self.messages.append(newMessage)  // 将消息添加到本地消息列表
                    print("Message sent successfully.")
                case .failure(let error):
                    print("Failed to send message: \(error)")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // 关闭 LeanCloud 客户端连接
    func closeConnection() {
        if let client = self.client {
            print("Attempting to close connection...")
            client.close { result in
                switch result {
                case .success:
                    print("IMClient connection closed successfully.")
                case .failure(let error):
                    print("Failed to close IMClient connection: \(error.localizedDescription)")
                }
            }
        } else {
            print("IMClient is nil, cannot close connection.")
        }
        self.client = nil
    }
    
//    // 加载历史消息
//    func loadMessageHistory() {
//        do {
//            try conversation?.queryMessage{ [weak self] result in
//                switch result {
//                case .success(let messages):
//                    self?.messages = messages.compactMap { message in
//                        if let textMessage = message as? IMTextMessage {
//                            print(textMessage)
//                            return Message(
//                                id: message.ID ?? UUID().uuidString,
//                                senderId: textMessage.fromClientID ?? "unknown",
//                                content: textMessage.text ?? "",
//                                timestamp: textMessage.sentDate ?? Date()
//                            )
//                        }
//                        return nil
//                    }
//                case .failure(let error):
//                    self?.onError = error
//                }
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
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
