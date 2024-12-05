//
//  PrivateChatListVIew.swift
//  InterAct
//
//  Created by admin on 2024/11/30.
//

import SwiftUI
import LeanCloud

struct PrivateChatListView: View {
    @StateObject private var viewModel = PrivateChatListViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.privateChats, id: \.partnerId) { chat in
                VStack{
                    HStack {
                        // 显示对方头像
                        if let avatarURL = URL(string: chat.partnerAvatarURL), !chat.partnerAvatarURL.isEmpty {
                            AsyncImage(url: avatarURL) { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(chat.partnerUsername)
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: PrivateChatView(currentUserId: viewModel.currentUserId, recipientUserId: chat.partnerId)) {
                        }
                    }
                }
            }
            .navigationTitle("私信列表")
            
            .onAppear {
                viewModel.fetchPrivateChats()  // 获取私聊列表
            }
            .alert(isPresented: $viewModel.isError) {
                Alert(title: Text("错误"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("确定")))
            }
        }
    }
    
    // 格式化时间
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}


extension DateFormatter {
    static var shortTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}
