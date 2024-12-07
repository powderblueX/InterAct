//
//  GroupChatManageView.swift
//  InterAct
//
//  Created by admin on 2024/12/7.
//

import SwiftUI

struct GroupChatManageView: View {
    @State var groupChat: GroupChatList
    // TODO: 管理
    var body: some View {
        ScrollView{
            // 显示群聊信息
            NavigationLink(destination: ActivityDetailView(activityId: groupChat.activityId)){
                Text("\(groupChat.activityName)")
                    .font(.title)
                    .padding()
                    .foregroundStyle(.orange)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

