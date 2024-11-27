//
//  UserListView.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import SwiftUI
import Kingfisher

struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()

    var body: some View {
        NavigationView {
            List(){
                if viewModel.isLoading {
                    ProgressView("加载中...")
                } else if let userInfo = viewModel.userInfo {
                    HStack {
                        // 显示用户头像
                        if let avatarURL = userInfo.avatarURL {
                            KFImage(URL(string: avatarURL.absoluteString))
                                .placeholder {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .foregroundColor(.gray)
                                }
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else {
                            // 如果 avatarURL 为空，显示默认头像
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .foregroundColor(.gray)  // 默认头像颜色
                        }
                        
                        
                        VStack(alignment: .leading) {
                            Text(userInfo.username)
                                .font(.headline)
                        }
                        
                        Spacer()
                        NavigationLink(destination: PrivateChatView(viewModel: PrivateChatViewModel(currentUserId: "6746dc6e2096fe04ef313a1d", recipientUserId: "6745d7b4da26173b54aff6de"))) {
                            
                        }
                    }
                    .navigationTitle("用户列表")
                }
            }
            .onAppear(){
                viewModel.loadUsers(objectId: "6745d7b4da26173b54aff6de") { result in
                    DispatchQueue.main.async {
                        viewModel.isLoading = false
                        switch result {
                        case .success(let userInfo):
                            viewModel.userInfo = userInfo
                        case .failure(let error):
                            viewModel.errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
    }
}
