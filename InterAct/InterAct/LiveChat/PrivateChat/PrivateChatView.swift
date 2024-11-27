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
        VStack {
            // 顶部显示对方的用户名
            Text(viewModel.recipientUserId) // 假设对方的用户名是 recipientUserId
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            // 消息列表
            ScrollView {
                ForEach(viewModel.messages) { message in
                    MessageRow(message: message, isCurrentUser: message.senderId == viewModel.currentUserId)
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
                    // 这里你可以添加调用相机或选择相册的逻辑
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
            viewModel.openChatSession()
        }
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.onError != nil },
            set: { _ in }
        )) {
            Alert(
                title: Text("错误"),
                message: Text((viewModel.onError as? LocalizedError)?.errorDescription ?? "未知错误"),
                dismissButton: .default(Text("确定"))
            )
        }
    }
}


