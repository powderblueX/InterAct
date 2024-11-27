//
//  GroupChatViewModel.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import Foundation
import LeanCloud
import Combine

//class GroupChatViewModel: ObservableObject {
//    @Published var messages: [PrivateMessage] = []
//    @Published var newMessage: String = ""
//    private var cancellables = Set<AnyCancellable>()
//    
//    private var chatId: String
//    
//    init(chatId: String) {
//        self.chatId = chatId
//        listenToMessages()
//    }
//    
//    // 监听群聊消息
//    func listenToMessages() {
//        let query = LCQuery(className: "Messages")
//        query.whereKey("chatId", equalTo: self.chatId)
//        query.find { result in
//            switch result {
//            case .success(let messages):
//                self.messages = messages.map { message in
//                    PrivateMessage(
//                        id: message.objectId!.stringValue,
//                        fromId: message["fromId"]!.stringValue,
//                        toId: message["toId"]!.stringValue,
//                        content: message["content"]!.stringValue,
//                        timestamp: message["timestamp"]!.dateValue
//                    )
//                }
//            case .failure(let error):
//                print("获取群聊消息失败: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    // 发送群聊消息
//    func sendMessage() {
//        let message = LCObject(className: "Messages")
//        message["fromId"] = LCString("currentUserId") // 获取当前用户 ID
//        message["chatId"] = LCString(chatId)
//        message["content"] = LCString(newMessage)
//        message["timestamp"] = LCDate(Date())
//        
//        message.save { result in
//            switch result {
//            case .success(_):
//                self.newMessage = ""
//                self.listenToMessages()  // 发送消息后重新获取消息
//            case .failure(let error):
//                print("发送群聊消息失败: \(error.localizedDescription)")
//            }
//        }
//    }
//}
