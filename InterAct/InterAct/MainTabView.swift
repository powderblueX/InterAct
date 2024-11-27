//
//  MainTabView.swift
//  EcoStep
//
//  Created by admin on 2024/11/19.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // 推荐活动
            CreateActivityView()
                .tabItem {
                    Image(systemName: "smiley")
                    Text("推荐活动")
                }
            
            // 附近活动
            NearbyActivitiesView()
                .tabItem {
                    Image(systemName: "map")
                    Text("附近活动")
                }

            // 即时聊天
            UserListView()
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
        .accentColor(.green) // 设置底部导航栏图标的选中颜色
    }
}

#Preview {
    MainTabView()
}
