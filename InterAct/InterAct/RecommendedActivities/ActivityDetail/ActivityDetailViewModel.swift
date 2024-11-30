//
//  ActivityDetailViewModel.swift
//  InterAct
//
//  Created by admin on 2024/11/29.
//

import Foundation

class ActivityDetailViewModel: ObservableObject {
    @Published var isImageSheetPresented: Bool = false
    @Published var showSaveImageAlert: Bool = false
    @Published var activity: Activity? = nil
    @Published var currentUserId: String = ""
    
    func fetchActivityDetail(activityId: String) {
        // 使用 LeanCloud SDK 获取活动详情
        LeanCloudService.fetchActivityDetails(activityId: activityId) { [weak self] result in
            switch result {
            case .success(let activity):
                self?.activity = activity
            case .failure(let error):
                print("获取活动详情失败: \(error)")
            }
        }
    }
    
    func getCurrentId(){
        guard let objectId = UserDefaults.standard.string(forKey: "objectId") else {
            // TODO: 用户登出
            return
        }
        currentUserId = objectId
    }
}
