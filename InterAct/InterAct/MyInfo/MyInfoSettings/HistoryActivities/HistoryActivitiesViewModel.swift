//
//  ActivitiesIParticipateinViewModel.swift
//  InterAct
//
//  Created by admin on 2024/12/11.
//

import Foundation

public class HistoryActivitiesViewModel: ObservableObject {
    @Published var currentUserId: String? = nil
    @Published var activities: [Activity] = []
    
    // 分页相关
    @Published var currentPage: Int = 1        // 当前页数
    @Published var totalPages: Int = 1      // 每次加载的活动数量
    private let pageSize = 10 // 每页加载 10 条活动
    @Published var isLoading: Bool = false    // 标记是否正在加载数据
    @Published var isLoadingMore: Bool = false // 是否正在加载更多数据
    @Published var hasMoreData: Bool = true // 是否还有更多数据
    @Published var isForMore: Bool = false
    
    // TODO: 退回到登入页面
    func fetchAllActivitiesIParticipatein(page: Int) {
        guard let currentUserId = UserDefaults.standard.string(forKey: "objectId") else {
            AppState.shared.isLoggedIn = false
            LeanCloudService.logout()
            return
        }
        
        self.currentUserId = currentUserId
        
        LeanCloudService.fetchAllActivitiesIParticipatein(currentUserId: currentUserId, page: page, pageSize: pageSize) { [weak self] fetchedActivities, totalPages in
            guard let self = self else { return }
            
            self.isLoading = false
            
            // 更新活动列表
            if let activities = fetchedActivities {
                if page == 1 {
                    self.activities = activities // 如果是第一页，替换活动列表

                } else if hasMoreData && isForMore {
                    self.activities.append(contentsOf: activities) // 如果是后续页，追加活动
                    isForMore = false
                }
                self.totalPages = totalPages
                self.hasMoreData = self.currentPage < self.totalPages
            } else {
                print("没有找到活动")
            }
        }
    }
    
    // 加载更多数据
    func loadMoreActivities() {
        guard !isLoading && hasMoreData else { return }
        
        isLoadingMore = true
        currentPage += 1
        isForMore = true
        fetchAllActivitiesIParticipatein(page: currentPage) // 继续加载活动
        isLoadingMore = false
    }
}
