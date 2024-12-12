//
//  PrivateChatView.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import SwiftUI
import LeanCloud

struct PrivateChatView: View {
    @StateObject private var viewModel: PrivateChatViewModel
    @State var privateChat: PrivateChatList
    
    @State private var messageText: String = ""
    @State private var selectedImage: UIImage?
    @State private var isAgreeable: Int = 0
    @State private var activityId: String = ""
    @State private var activityName: String = ""
    
    init(conversationID: String, privateChat: PrivateChatList, sendParticipateIn: SendParticipateIn? = nil) {
        _viewModel = StateObject(wrappedValue: PrivateChatViewModel(privateChatId: conversationID, sendParticipateIn: sendParticipateIn))
        self.privateChat = privateChat
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 消息列表
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // 顶部加载触发器
                        if viewModel.hasMoreMessages {
                            ProgressView("加载中...")
                                .onAppear {
                                    viewModel.loadMoreMessages() // 滚动到顶部时触发加载更多
                                }
                        }

                        ForEach(viewModel.messages) { message in
                            PrivateMessageRowView(isAgreeable: $isAgreeable, activityId: $activityId, activityName: $activityName, message: message, activityDict: viewModel.activityDict ?? [:], isCurrentUser: message.senderId == viewModel.currentUserId, partner: viewModel.partner ?? Partner(id: "", username: "加载中...", avatarURL: URL(filePath: ""), gender: "加载中...", exp: 0), currentUserId: viewModel.currentUserId ?? "")
                                .id("\(message.senderId)_\(message.timestamp.timeIntervalSince1970)")
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                    viewModel.fetchMyFutureActivity()
                }
                .onChange(of: isAgreeable) {
                    switch isAgreeable {
                    case 1:
                        viewModel.sendMessage("好的，我同意你参加：“\(activityName)”")
                        if let userId = viewModel.partner?.id {
                            if !userId.isEmpty{
                                // 调用静态方法 TODO: 可能需要改到VM中
                                LeanCloudService.addUserToConversationAndActivity(userId: userId, activityId: activityId) { success, message in
                                    if success {
                                        print(message)  // 成功消息
                                    } else {
                                        print("Error: \(message)")  // 失败消息
                                    }
                                }
                            }
                        }
                    case -1:
                        viewModel.sendMessage("抱歉，我拒绝你来参加：“\(activityName)”")
                    default: break
                    }
                    activityId = ""
                    activityName = ""
                    isAgreeable = 0
                }
            }
            
            // 输入框和发送按钮
            HStack {
                TextField("请输入消息...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 24)
                
                Button(action: {
                    viewModel.sendMessage(messageText)
                    messageText = ""
                }) {
                    Text("发送")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(5)
                }
                
                // 选择图片按钮
                Button(action: {
                    // TODO: 可以添加调用相机或选择相册的逻辑
                    viewModel.selectImage()
                }) {
                    Image(systemName: "photo")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .padding()
        }
        .onAppear {
            IMClientManager.shared.setIsInChatView("PrivateChatView") // 进入私信详情
            if privateChat.privateChatId.isEmpty {
                viewModel.createConversation(to: privateChat.partnerId)
            } else {
                viewModel.fetchConversation()
            }
            viewModel.fetchUserInfo(for: privateChat.partnerId)
        }
        .onDisappear{
            viewModel.readMessages()
        }
        .navigationBarTitle("\(privateChat.partnerUsername)", displayMode: .inline)
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.onError != nil },
            set: { _ in }
        )) {
            Alert(
                title: Text("错误"),
                message: Text(viewModel.onError?.localizedDescription ?? "未知错误"),
                dismissButton: .default(Text("确定"))
            )
        }
    }
}


