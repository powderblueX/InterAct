//
//  MainTabView.swift
//  EcoStep
//
//  Created by admin on 2024/11/19.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var imClientManager = IMClientManager.shared
    
    var body: some View {
        TabView {
            // 推荐活动
            RecommendActivitiesView()
                .tabItem {
                    Image(systemName: "smiley")
                    Text("推荐活动")
                }
            
            // 附近活动
            HeatmapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("热力图")
                }
            
            // 即时聊天
            LiveChatView()
                .tabItem {
                    Image(systemName: "envelope")
                    Text("即时聊天")
                }
            
            // 个人信息
            MyInfoView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("我")
                }
        }
        .accentColor(.blue) // 设置底部导航栏图标的选中颜色
        .onAppear{
            imClientManager.initializeClient(){ result in
                switch result{
                case .success():
                    print("success")
                    imClientManager.fetchAllConversations() {result in
                        switch result{
                        case .success(let conversations):
                            imClientManager.conversations = conversations
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                case .failure(let error):
                    print("failure:\(error)")
                }
            } 
        }
    }
}
