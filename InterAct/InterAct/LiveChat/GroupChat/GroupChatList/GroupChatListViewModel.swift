//
//  GroupChatListViewModel.swift
//  InterAct
//
//  Created by admin on 2024/12/6.
//

import Foundation
import LeanCloud

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
        NotificationCenter.default.addObserver(self, selector: #selector(refreshGroupChats), name: .updateGroupChatList, object: nil)
    }
    @objc private func refreshGroupChats() {
        // 重新获取或更新未读消息数
        fetchGroupChats()
    }
    
    
    func fetchGroupChats() {
        // 查询当前用户参与的私聊会话（包括自己作为创建者或接收者）
        LeanCloudService.fetchGroupChats() { [weak self] result in
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
