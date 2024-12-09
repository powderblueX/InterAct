//
//  IMClientManager.swift
//  InterAct
//
//  Created by admin on 2024/12/8.
//

import Foundation
import LeanCloud

class IMClientManager: NSObject, ObservableObject {
    static let shared = IMClientManager()
    var lastMessages: [String: IMTextMessage] = [:]
    private var client: IMClient?
    private var currentUserId: String?
    private var isInChatView: String = "PrivateChatListView"
    @Published var conversations: [IMConversation] = []
    
    func initializeClient(completion: @escaping (Result<Void, Error>) -> Void) {
        guard client == nil else {
            completion(.success(())) // 如果已经初始化，则直接返回成功
            return
        }
        guard let userId = UserDefaults.standard.string(forKey: "objectId") else {
            LeanCloudService.logout()
            return
        }
        currentUserId = userId
        print((currentUserId ?? "1222222")+"22222222222")
        
        do {
            client = try IMClient(ID: userId)
            client?.delegate = self
            
            client?.open { result in
                switch result {
                case .success:
                    print("IMClient initialized and connected successfully.")
                    completion(.success(()))
                case .failure(let error):
                    print("Failed to open IMClient: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        } catch {
            print("IMClient initialization failed: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    func getClient() -> IMClient? {
        return client
    }
    
    func getCurrentUserId() -> String? {
        return currentUserId
    }
    
    func setIsInChatView(_ inChatView: String) {
        self.isInChatView = inChatView
    }
    
    func fetchAllConversations(completion: @escaping (Result<[IMConversation], Error>) -> Void) {
        guard let client = client else {
            completion(.failure(NSError(domain: "IMClient is not initialized", code: -1, userInfo: nil)))
            return
        }
        
        let query = client.conversationQuery
        //query.limit = 100 // 设置最大查询条数，默认100
        do {
            try query.findConversations { result in
                switch result {
                case .success(let conversations):
                    for conversation in conversations {
                        print(conversation.ID)
                    }
                    print("Fetched conversations successfully.")
                    // 保存会话实例到本地
                    completion(.success(conversations))
                case .failure(let error):
                    print("Failed to fetch conversations: \(error)")
                    completion(.failure(error))
                }
            }
        } catch {
            print("Failed to fetch conversations: \(error)")
        }
    }
    
    func closeClient(completion: (() -> Void)? = nil) {
        guard let client = client else {
            completion?() // 如果客户端已关闭或不存在，则直接调用回调
            return
        }
        
        client.close { result in
            switch result {
            case .success:
                print("IMClient closed successfully.")
            case .failure(let error):
                print("Failed to close IMClient: \(error.localizedDescription)")
            }
            self.client = nil
            completion?()
        }
    }
}

extension IMClientManager: IMClientDelegate {
    func client(_ client: LeanCloud.IMClient, conversation: LeanCloud.IMConversation, event: LeanCloud.IMConversationEvent) {
        switch event {
        case .message(let messageEvent):
            switch messageEvent {
            case .received(let message):
                // 找到对应的会话
                if let textMessage = message as? IMTextMessage {
                    DispatchQueue.main.async {
                        self.lastMessages[conversation.ID] = textMessage
                        if self.isInChatView == "PrivateChatView" {
                            NotificationCenter.default.post(name: .newMessagePrivateChatReceived, object: nil, userInfo: [
                                "conversationID": conversation.ID,
                                "message": textMessage
                            ])
                        } else if self.isInChatView == "GroupChatView" {
                            NotificationCenter.default.post(name: .newMessagePrivateChatReceived, object: nil, userInfo: [
                                "conversationID": conversation.ID,
                                "message": textMessage
                            ])
                        } else if self.isInChatView == "GroupChatListView" {
                            NotificationCenter.default.post(name: .updateGroupChatList, object: nil)
                        } else {
                            NotificationCenter.default.post(name: .updatePrivateChatList, object: nil)
                        }
                    }
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    // 示例：处理一些客户端的委托方法
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

extension Notification.Name {
    static let newMessageGroupChatReceived = Notification.Name("newMessageGroupChatReceived")
    static let newMessagePrivateChatReceived = Notification.Name("newMessagePrivateChatReceived")
    static let updateGroupChatList = Notification.Name("updateGroupChatList")
    static let updatePrivateChatList = Notification.Name("updatePrivateChatList")
}



    
