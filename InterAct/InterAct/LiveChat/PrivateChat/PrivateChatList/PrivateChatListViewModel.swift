//
//  PrivateChatListViewModel.swift
//  InterAct
//
//  Created by admin on 2024/11/30.
//

import Foundation
import LeanCloud

class PrivateChatListViewModel: ObservableObject {
    @Published var privateChats: [PrivateChatList] = []   // 用于存储私聊列表

    @Published var errorMessage: String? = nil         // 错误消息绑定
    @Published var isError: Bool = false
    
    @Published var currentUserId: String = ""            // 当前用户ID
    
    init() {
        // 设置当前用户ID
        if let userId = UserDefaults.standard.string(forKey: "objectId") {
            self.currentUserId = userId
        }
    }
    
    // 获取与当前用户相关的私聊会话
    func fetchPrivateChats() {
        // 查询当前用户参与的私聊会话（包括自己作为创建者或接收者）
        LeanCloudService.fetchPrivateChats(for: currentUserId) { [weak self] result in
            switch result {
            case .success(let chats):
                DispatchQueue.main.async {
                    self?.privateChats = chats // 更新 UI
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription // 错误处理
                    self?.isError = true
                }
            }
        }
    }
//    func fetchGroupChats() {
//        // 查询当前用户参与的私聊会话（包括自己作为创建者或接收者）
//        LeanCloudService.fetchGroupChats(for: currentUserId) { [weak self] result in
//            switch result {
//            case .success(let chats):
//                DispatchQueue.main.async {
//                    self?.privateChats = chats // 更新 UI
//                }
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    self?.errorMessage = error.localizedDescription // 错误处理
//                    self?.isError = true
//                }
//            }
//        }
//    }
}

    // TODO: 获取私聊会话的最新消息
//    // 获取私聊会话的最新消息
//    private func fetchLatestMessage(for conversation: LCObject, completion: @escaping (String, Date) -> Void) {
//        let messagesQuery = LCQuery(className: "IMMessage")
//        messagesQuery.whereKey("conversation", .equalTo(conversation))
//        messagesQuery.limit = 1 // 只获取最新的一条消息
//        messagesQuery.find { result in
//            switch result {
//            case .success(let messages):
//                if let message = messages.first {
//                    let messageText = message["text"]?.stringValue ?? "没有内容"
//                    let timestamp = message["sentDate"]?.dateValue ?? Date()
//                    completion(messageText, timestamp)
//                } else {
//                    completion("没有消息", Date()) // 如果没有消息
//                }
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    self.errorMessage = error.localizedDescription // 错误处理
//                }
//            }
//        }
//    }

