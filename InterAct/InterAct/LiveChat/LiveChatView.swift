//
//  LiveChatView.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import SwiftUI

struct LiveChatView: View {
    var body: some View {
        TabView {
            // 私信
            PrivateChatListView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("私信")
                }

            // 群聊
            MyInfoView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("群聊")
                }
        }
        .accentColor(.green) // 设置底部导航栏图标的选中颜色
    }
}

//#Preview {
//    LiveChatView()
//}
