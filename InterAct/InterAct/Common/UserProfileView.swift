//
//  UserProfileView.swift
//  InterAct
//
//  Created by admin on 2024/12/7.
//

import SwiftUI
import Kingfisher

struct UserProfileView: View {
    @State var userInfo: ParticipantInfo
    @State var isAvatarSheetPresented: Bool = false
    @State var showSaveImageAlert: Bool = false
    
    var body: some View {
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
                
                // 用户名
                Text(userInfo.username).font(.title)
                
                // 用户性别和生日
                Text("性别：\(userInfo.gender)")
                
                // 用户的声望
                if userInfo.exp > 0 {
                    Text("声望：+\(userInfo.exp)")
                } else {
                    Text("声望：\(userInfo.exp)")
                }
            }
            .padding()
        }
        // 弹窗展示头像预览
        .sheet(isPresented: $isAvatarSheetPresented) {
            if let avatarURL = userInfo.avatarURL {
                AvatarPreviewView(imageURL: avatarURL, isPresented: $isAvatarSheetPresented)
            }
        }
    }
}
