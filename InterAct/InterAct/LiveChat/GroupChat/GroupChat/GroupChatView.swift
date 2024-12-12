//
//  GroupChatView.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import SwiftUI
import LeanCloud

struct GroupChatView: View {
    @StateObject private var viewModel: GroupChatViewModel  // 绑定视图模型
    @State var currentUser: LCUser = LCUser()
    @State var groupChat: GroupChatList
    @State private var messageText: String = ""  // 用户输入的消息内容
    
    init(conversationID: String, groupChat: GroupChatList) {
        _viewModel = StateObject(wrappedValue: GroupChatViewModel(conversationID: conversationID))
        self.groupChat = groupChat
    }
    
    var body: some View {
        VStack {            
            ScrollViewReader { proxy in
                ScrollView {
                    messageContent
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if let lastMessage = viewModel.messages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            HStack {
                TextField("输入消息...", text: $messageText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.leading)
                
                Button(action: {
                    viewModel.sendMessage(messageText)
                    messageText = ""
                }) {
                    Text("发送")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.trailing)
            }
            .padding()
        }
        .onAppear {
            IMClientManager.shared.setIsInChatView("GroupChatView") 
            viewModel.joinGroupChat(with: groupChat)
            viewModel.fetchAllparticipantsInfo(ParticipantIds: groupChat.participantIds)
        }
        .onDisappear{
            viewModel.readMessages()
        }
        .navigationBarTitle("\(groupChat.activityName)(\(groupChat.participantIds.count))", displayMode: .inline)
        .navigationBarItems(trailing: NavigationLink(destination: GroupChatManageView(groupChat: groupChat, participantsInfo: viewModel.participantsInfo ?? [], currentUserId: viewModel.currentUserId ?? "")) {
            Image(systemName: "gearshape")
                .imageScale(.large)
        })
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("提示"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private var messageContent: some View {
        LazyVStack(spacing: 0) {
            // 顶部加载触发器
            if viewModel.hasMoreMessages {
                ProgressView("加载中...")
                    .onAppear {
                        viewModel.loadMoreMessages() // 滚动到顶部时触发加载更多
                    }
            }
            ForEach(viewModel.messages) { message in
                let matchingParticipant = viewModel.participantsInfo?.first(where: { $0.id == message.senderId })
                GroupMessageRowView(message: message, isCurrentUser: message.senderId == viewModel.currentUserId, senderInfo: matchingParticipant ?? ParticipantInfo(id: "加载中...", username: "加载中...", avatarURL: URL(filePath: "加载中..."), gender: "加载中...", exp: 0))
                    .id(message.id)  // 给每条消息设置唯一的 id
            }
        }
    }
}
