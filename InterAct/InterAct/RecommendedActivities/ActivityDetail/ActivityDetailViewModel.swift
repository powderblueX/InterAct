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
    @Published var activity: Activity? = nil  // 存储活动信息
    
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
    
    
}
