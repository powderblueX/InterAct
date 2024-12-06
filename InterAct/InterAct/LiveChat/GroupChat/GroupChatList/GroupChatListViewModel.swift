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
                    self?.groupChats = chats // 更新 UI
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription // 错误处理
                    self?.isError = true
                }
            }
        }
    }
    
}
