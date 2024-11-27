//
//  UserProfileView.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

//import SwiftUI
//
//struct UserProfileView: View {
//    var user: User
//    
//    var body: some View {
//        VStack {
//            // 显示用户头像
//            AsyncImage(url: URL(string: user.avatarURL)) { image in
//                image.resizable()
//                    .scaledToFill()
//                    .clipShape(Circle())
//                    .frame(width: 100, height: 100)
//            } placeholder: {
//                Circle().fill(Color.gray).frame(width: 100, height: 100)
//            }
//            
//            // 显示用户名
//            Text(user.username)
//                .font(.title)
//                .padding()
//            
//            Spacer()
//            
//            // 私信按钮
//            NavigationLink(destination: PrivateChatView(toUserId: user.id, toUser: user)) {
//                Text("私信")
//                    .foregroundColor(.blue)
//                    .padding()
//            }
//        }
//        .navigationTitle("用户信息")
//    }
//}


