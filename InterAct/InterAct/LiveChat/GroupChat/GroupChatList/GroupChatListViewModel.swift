//
//  GroupChatListViewModel.swift
//  InterAct
//
//  Created by admin on 2024/12/6.
//

import Foundation

class GroupChatListViewModel: ObservableObject {
    @Published var groupChats: [GroupChatList] = []   // 用于存储私聊列表
    @Published var errorMessage: String? = nil         // 错误消息绑定
    @Published var isError: Bool = false
    @Published var currentUserId: String = ""            // 当前用户ID
    
    init() {
        // 设置当前用户ID
        if let userId = UserDefaults.standard.string(forKey: "objectId") {
            self.currentUserId = userId
        }
    }
    
    func fetchGroupChats() {
        // 查询当前用户参与的私聊会话（包括自己作为创建者或接收者）
        LeanCloudService.fetchGroupChats(for: currentUserId) { [weak self] result in
            switch result {
            case .success(let chats):
                DispatchQueue.main.async {
                    self?.groupChats = chats.sorted(by: {$0.lmDate>$1.lmDate}) // 更新 UI
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription // 错误处理
                    self?.isError = true
                }
            }
        }
    }
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"  // 格式化为：年-月-日 时:分:秒
        return formatter.string(from: date)
    }
}

//class GroupChatListViewModel: ObservableObject {
//    @Published var groupChats: [GroupChatList] = []   // 用于存储私聊列表
//    @Published var errorMessage: String? = nil         // 错误消息绑定
//    @Published var isError: Bool = false
//    @Published var currentUserId: String = ""            // 当前用户ID
//    @Published var isClientClosed: Bool = true
//    @Published var isToChat: Bool = false
//    
//    private var client: IMClient?
//    
//    init() {
//        // 设置当前用户ID
//        if let userId = UserDefaults.standard.string(forKey: "objectId") {
//            self.currentUserId = userId
//        }
//    }
//    
//    func initializeIMClient() {
//        do {
//            client = try IMClient(ID: currentUserId)
//            client?.delegate = self
//            client?.open { result in
//                switch result {
//                case .success:
//                    print("IMClient connected successfully")
//                    self.isClientClosed = false
//                    self.fetchGroupChats()
//                    // 获取群聊列表
//                case .failure(let error):
//                    print("Failed to open IMClient connection: \(error.localizedDescription)")
//                    self.errorMessage = error.localizedDescription
//                    self.isError = true
//                }
//            }
//        } catch {
//            print("IMClient initialization failed: \(error.localizedDescription)")
//            self.errorMessage = error.localizedDescription
//            self.isError = true
//        }
//    }
//    
//    func fetchGroupChats() {
//        // 查询当前用户参与的私聊会话（包括自己作为创建者或接收者）
//        LeanCloudService.fetchGroupChats(for: currentUserId) { [weak self] result in
//            switch result {
//            case .success(let chats):
//                DispatchQueue.main.async {
//                    self?.groupChats = chats // 更新 UI
//                    self?.updateUnreadMessageCount(for: chats)
//                }
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    self?.errorMessage = error.localizedDescription // 错误处理
//                    self?.isError = true
//                }
//            }
//        }
//    }
//    
//    // 更新每个群聊的未读消息数量
//    func updateUnreadMessageCount(for chats: [GroupChatList]) {
//        for index in 0..<chats.count {
//            var chat = chats[index]
//            do {
//                try client?.conversationQuery.getConversation(by: chat.groupChatId) { result in
//                    switch result {
//                    case .success(let conversation):
//                        print("Successfully created conversation")
//                        chat.conversation = conversation
//                        // 使用 LeanCloud 的 SDK 获取该会话的未读消息数量
//                        if let conversation = chat.conversation {
//                            let unreadCount = conversation.unreadMessageCount
//                            // 更新群聊对象中的未读消息数量
//                            self.groupChats[index].unreadMessagesCount = unreadCount
//                        }
//                    case .failure(error: let error):
//                        self.errorMessage = error.localizedDescription // 错误处理
//                        self.isError = true
//                    }
//                }
//            } catch {
//                self.errorMessage = error.localizedDescription // 错误处理
//                self.isError = true
//            }
//        }
//    }
//    
//    // 关闭 LeanCloud 客户端连接
//    func closeConnection() {
//        if let client = self.client {
//            print("Attempting to close connection...")
//            //if self.isToChat {
//                self.isClientClosed = true
//           //     self.isToChat.toggle()
//           // }
//            client.close { result in
//                switch result {
//                case .success:
//                    print("IMClient connection closed successfully.")
//                case .failure(let error):
//                    print("Failed to close IMClient connection: \(error.localizedDescription)")
//                }
//            }
//        } else {
//            print("IMClient is nil, cannot close connection.")
//        }
//        self.client = nil
//    }
//}
//
//
//extension GroupChatListViewModel: IMClientDelegate {
//    func client(_ client: LeanCloud.IMClient, conversation: LeanCloud.IMConversation, event: LeanCloud.IMConversationEvent) {
//        switch event {
//        case .message(let messageEvent):
//            switch messageEvent {
//            case .received(_):
//                break
//            default:
//                break
//            }
//        default:
//            break
//        }
//    }
//    
//    func client(_ client: IMClient, event: IMClientEvent) {
//        print("Received event: \(event)") // 打印事件类型
//        switch event {
//        case .sessionDidClose(let error):
//            print("Session closed with error: \(error.localizedDescription)")
//        case .sessionDidOpen:
//            print("Session opened successfully.")
//        case .sessionDidPause(let error):
//            print("Session paused with error: \(error.localizedDescription)")
//        case .sessionDidResume:
//            print("Session resumed successfully.")
//        }
//    }
//}
