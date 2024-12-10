//
//  MainTabView.swift
//  EcoStep
//
//  Created by admin on 2024/11/19.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var imClientManager = IMClientManager.shared
    @Environment(\.colorScheme) var colorScheme
    
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
            updateAppIcon(for: colorScheme == .dark)
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
    func updateAppIcon(for isDarkMode: Bool) {
        print("当前深色模式：\(isDarkMode ? "是" : "否")")
        guard UIApplication.shared.supportsAlternateIcons else {
            print("不支持动态图标切换")
            return
        }
        let iconName = isDarkMode ? "DarkModeIcon" : nil
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("图标切换失败: \(error.localizedDescription)")
            } else {
                print("图标切换成功")
            }
        }
    }
}
