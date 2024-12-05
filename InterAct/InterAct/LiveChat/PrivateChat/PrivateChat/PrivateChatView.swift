//
//  PrivateChatView.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import SwiftUI

struct PrivateChatView: View {
    @ObservedObject private var viewModel: PrivateChatViewModel
    @State private var messageText: String = ""
    @State private var selectedImage: UIImage?
    
    init(viewModel: PrivateChatViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(viewModel.chat?.partnerUsername ?? "加载中...")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            // 消息列表
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.messages) { message in
                            MessageRowView(message: message, isCurrentUser: message.senderId != viewModel.currentUserId, chat: viewModel.chat ?? PrivateChat(partnerId: "加载中...", partnerUsername: "加载中...", partnerAvatarURL: ""))
                                .id(message.id)  // 给每条消息设置唯一的 id
                        }
                    }
                }
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
            viewModel.fetchUserInfo(for: viewModel.recipientUserId)
            viewModel.openChatSession()
        }
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


