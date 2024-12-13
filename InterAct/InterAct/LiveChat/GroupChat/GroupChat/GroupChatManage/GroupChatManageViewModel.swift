//
//  GroupChatManageViewModel.swift
//  InterAct
//
//  Created by admin on 2024/12/12.
//

import Foundation
import SwiftUI

class GroupChatManageViewModel: ObservableObject {
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    @Published var activityIsDone: Bool = false
    
    @Published var isEditing = false  // 控制是否编辑状态
    @Published var isShake = false  // 控制图片是否抖动
    @Published var selectedParticipant: ParticipantInfo?  // 当前选中的参与者
    
    @Published var participantsInfo: [ParticipantInfo]? = nil
    @Published var confirmationAction: (() -> Void)?
    @Published var confirmationMessage: String?
    @Published var showConfirmationDialog = false
    
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
    
    func dismissGroupButtonTapped(activityId: String, conversationId: String) {
        LeanCloudService.dismissGroup(activityId: activityId, conversationId: conversationId) { result in
            switch result {
            case .success:
                print("成功解散群聊并删除活动")
            case .failure(let error):
                print("失败: \(error.localizedDescription)")
                // 显示错误提示
            }
        }
    }
    
    func kickOutParticipant(participantId: String, conversationId: String, activityId: String) {
        errorMessage = nil
        
        LeanCloudService.removeParticipant(participantId: participantId, conversationId: conversationId, activityId: activityId) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    print("踢人成功！")
                } else {
                    self?.errorMessage = error?.localizedDescription ?? "操作失败"
                    print("踢人失败：\(String(describing: self?.errorMessage))")
                }
            }
        }
    }
    
    func updateParticipantsInfo(participantsInfo: [ParticipantInfo]) {
        self.participantsInfo = participantsInfo
    }
    
    func toggleEditing() {
        withAnimation {
            isEditing.toggle()
        }
        // 延迟更新抖动状态，确保动画顺利切换
        DispatchQueue.main.async {
            if self.isEditing {
                self.isShake = true  // 开始抖动
            } else {
                self.isShake = false  // 停止抖动
            }
        }
    }
    
    func confirmAction(message: String, action: @escaping () -> Void) {
        confirmationMessage = message
        confirmationAction = action
        showConfirmationDialog = true
    }
}
