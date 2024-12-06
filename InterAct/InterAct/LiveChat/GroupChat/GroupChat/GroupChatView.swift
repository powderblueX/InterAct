//
//  GroupChatView.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import SwiftUI
import LeanCloud

struct GroupChatView: View {
    @StateObject var viewModel = GroupChatViewModel()  // 绑定视图模型
    @State var currentUser: LCUser = LCUser()
    @State var groupChat: GroupChatList
    
    @State private var messageText: String = ""  // 用户输入的消息内容
    
    
    var body: some View {
        VStack {
            // 显示群聊信息
            Text("\(groupChat.activityName)")
                .font(.title2)
                .padding()
            
            //                    // 显示群聊中的历史消息
            //                    List(viewModel.messages, id: \.timestamp) { message in
            //                        Text(message.content)
            //                            .padding()
            //                            .background(message.senderId == viewModel.currentUserId ? Color.blue : Color.gray.opacity(0.3))
            //                            .foregroundColor(.white)
            //                            .cornerRadius(8)
            //                            .frame(maxWidth: .infinity, alignment: message.senderId == viewModel.currentUserId ? .trailing : .leading)
            //                    }
            //                    .listStyle(PlainListStyle())
            
            ScrollViewReader { proxy in
                ScrollView {
                    messageContent
                    .onAppear {
                        DispatchQueue.main.async {
                            if let lastMessage = viewModel.messages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.messages) {
                        // 当消息更新时滚动到底部
                        if let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
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
            
            
            //                Button(action: {
            //                    // 创建或加入群聊
            //                    viewModel.createOrJoinGroupChat(activityId: activityId, user: currentUser, participants: viewModel.participants) { success, errorMessage in
            //                        if success {
            //                            print("群聊加入成功")
            //                            alertMessage = "成功加入群聊!"
            //                        } else {
            //                            print("群聊加入失败")
            //                            alertMessage = errorMessage ?? "操作失败"
            //                        }
            //                        showAlert = true
            //                    }
            //                }) {
            //                    Text(viewModel.groupChatID == nil ? "申请加入群聊" : "已加入群聊")
            //                        .padding()
            //                        .background(viewModel.groupChatID == nil ? Color.blue : Color.green)
            //                        .foregroundColor(.white)
            //                        .cornerRadius(8)
            //                }
            //                .padding(.bottom)
            //            }
        }
        .onAppear {
            viewModel.initializeIMClient(){ success in
                if success{
                    viewModel.joinGroupChat(with: groupChat)
                }
            }
            viewModel.fetchAllparticipantsInfo(ParticipantIds: groupChat.participantIds)
        }
        .onDisappear{
            viewModel.closeConnection()
        }
        .navigationBarTitle("群聊", displayMode: .inline) // TODO: 推广
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("提示"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private var messageContent: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.messages) { message in
                let matchingParticipant = viewModel.participantsInfo?.first(where: { $0.id == message.senderId })
                GroupMessageRowView(message: message, isCurrentUser: message.senderId == viewModel.currentUserId, senderInfo: matchingParticipant ?? ParticipantInfo(id: "加载中...", username: "加载中...", avatarURL: URL(filePath: "加载中..."), gender: "加载中...", exp: 0))
                    .id(message.id)  // 给每条消息设置唯一的 id
            }
        }
    }
}


extension IMMessage {
    // 判断消息是否来自当前用户
    var isMine: Bool {
        guard let currentUserId = UserDefaults.standard.string(forKey: "objectId") else {
            return false
        }
        return self.fromClientID == currentUserId  // 假设 'from' 属性表示消息的发送者 ID
    }
}
