//
//  GroupChatManageViewModel.swift
//  InterAct
//
//  Created by admin on 2024/12/12.
//

import Foundation

class GroupChatManageViewModel: ObservableObject {
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    @Published var activityIsDone: Bool = false
    
    func markActivityAsDone(userId: String, activityId: String) {
        LeanCloudService.setActivityAsDone(userId: userId, activityId: activityId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("活动状态已更新为完成")
                    self.activityIsDone = true
                case .failure(let error):
                    print("更新活动状态失败: \(error.localizedDescription)")
                    self.activityIsDone = false
                }
            }
        }
    }

    func exitGroupAndActivity(conversationId: String, userId: String, activityId: String) {
        isProcessing = true
        errorMessage = nil
        
        LeanCloudService.exitGroupAndActivity(conversationId: conversationId, userId: userId, activityId: activityId, isDone: activityIsDone) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessing = false
                switch result {
                case .success:
                    print("退出成功")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("退出失败")
                }
            }
        }
    }
    
    func loadActivityStatus(activityId: String) {
        LeanCloudService.fetchActivityStatus(activityId: activityId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let isDone):
                    self.activityIsDone = isDone
                    print("活动状态已加载: \(isDone ? "已结束" : "进行中")")
                case .failure(let error):
                    print("加载活动状态失败: \(error.localizedDescription)")
                }
            }
        }
    }
}
