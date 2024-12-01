//
//  MyInfoView.swift
//  InterAct
//
//  Created by admin on 2024/11/23.
//

import SwiftUI

import SwiftUI
import Kingfisher
import Foundation

struct MyInfoView: View {
    @StateObject private var viewModel = MyInfoViewModel()
    @State private var isAvatarSheetPresented = false // 控制头像预览弹窗
    @State private var showSaveImageAlert = false // 控制保存提示

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 37){
                if viewModel.isLoading {
                    ProgressView("加载中...")
                } else if let userInfo = viewModel.userInfo {
                    ScrollView {
                        VStack(spacing: 20) {
                            // 用户头像
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
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        // 点击头像，显示大图
                                        isAvatarSheetPresented = true
                                    }
                                    .contextMenu {
                                        // 长按头像弹出保存选项
                                        Button(action: {
                                            showSaveImageAlert = true
                                        }) {
                                            Label("保存图片", systemImage: "square.and.arrow.down")
                                        }
                                    }
                            } else {
                                // 如果 avatarURL 为空，显示默认头像
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .foregroundColor(.gray)  // 默认头像颜色
                            }
                            
                            // 用户名、邮箱
                            Text(userInfo.username).font(.title)
                            Text(userInfo.email).font(.subheadline).foregroundColor(.gray)
                            
                            // 用户性别和生日
                            Text("性别：\(userInfo.gender)")
                            Text("生日：\(userInfo.birthday, style: .date)").environment(\.locale, Locale(identifier: "zh_CN"))
                            
                            // 用户的兴趣标签
                            Text("我的兴趣标签：\(userInfo.interest.joined(separator: "、"))")
                            
                            // 用户的声望
                            if userInfo.exp > 0 {
                                Text("我的声望：+\(userInfo.exp)")
                            } else {
                                Text("我的声望：\(userInfo.exp)")
                            }
                            
                            HStack{
                                // 用户帖子和收藏
                                Section(header: Text("我的帖子")) {
                                    ForEach(userInfo.posts) { post in
                                        NavigationLink(destination: PostDetailView(post: post)) {
                                            Text(post.title)
                                        }
                                    }
                                }
                                
                                Section(header: Text("我的收藏")) {
                                    ForEach(userInfo.favorites) { post in
                                        NavigationLink(destination: PostDetailView(post: post)) {
                                            Text(post.title)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .navigationBarItems(trailing: NavigationLink(destination: SettingsView(userInfo: $viewModel.userInfo)) {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                    })
                } else if let errorMessage = viewModel.errorMessage {
                    Text("加载失败: \(errorMessage)")
                }
            }
        }
        // 弹窗展示头像预览
        .sheet(isPresented: $isAvatarSheetPresented) {
            if let avatarURL = viewModel.userInfo?.avatarURL {
                AvatarPreviewView(imageURL: avatarURL, isPresented: $isAvatarSheetPresented)
            }
        }
        .onAppear {
            // 视图每次出现时重新加载用户信息
            viewModel.fetchUserInfo()
        }
    }
}

// TODO:帖子详情视图
struct PostDetailView: View {
    let post: MyInfoModel.Post

    var body: some View {
        Text(post.content)
            .navigationTitle(post.title)
    }
}

