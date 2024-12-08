//
//  MessageRow.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import SwiftUI

struct PrivateMessageRowView: View {
    @Binding var isAgreeable: Int
    @Binding var activityId: String
    @Binding var activityName: String
    
    @StateObject private var viewModel = PrivateMessageRowViewModel()
    @State var message: Message
    @State var activityDict: [String: [String]]
    let isCurrentUser: Bool
    let partner: Partner
    let currentUserId: String
    
    var body: some View {
        HStack {
            if isCurrentUser {
                userMessageView
                    .padding(.bottom, 10)
            } else {
                partnerMessageView
                    .padding(.bottom, 10)
            }
        }
        .padding(isCurrentUser ? .leading : .trailing, 40)
        .padding(isCurrentUser ? .trailing : .leading, 10)
        .padding(.vertical, 4)
        .onAppear {
            message.content = viewModel.updateContent(content: message.content)
        }
    }

    private var partnerMessageView: some View {
        HStack(alignment: .top) {
            
            NavigationLink(destination: UserProfileView(userInfo: ParticipantInfo(id: partner.id, username: partner.username, avatarURL: partner.avatarURL, gender: partner.gender , exp: partner.exp))){
                avatarImage(url: partner.avatarURL?.absoluteString ?? "")
            }
                        
            VStack(alignment: .leading) {
                messageContent
                messageTimestamp
                if !isCurrentUser && (viewModel.activityId != nil) {
                    if let activityId = viewModel.activityId {
                        HStack(spacing:1){
                            NavigationLink(destination: ActivityDetailView(activityId: activityId)){
                                Text("查看活动")
                                    .padding(3)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .font(.subheadline)  // 调整字体大小
                                    .frame(width: 100, height: 10)  // 限制宽度和高度
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if !viewModel.checkIsParticipatory(activityDict: activityDict, partner: partner) {
                                HStack {
                                    Button(action: {
                                        isAgreeable = 1
                                        self.activityId = viewModel.activityId ?? ""
                                        self.activityName = viewModel.activityName ?? "加载中..."
                                    }) {
                                        Text("同意")
                                            .padding(3)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                            .font(.subheadline)  // 调整字体大小
                                            .frame(width: 50, height: 10)  // 限制宽度和高度
                                    }
                                    
                                    Button(action: {
                                        isAgreeable = -1
                                        self.activityId = viewModel.activityId ?? ""
                                        self.activityName = viewModel.activityName ?? "加载中..."
                                    }) {
                                        Text("拒绝")
                                            .padding(3)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                            .font(.subheadline)  // 调整字体大小
                                            .frame(width: 50, height: 10)  // 限制宽度和高度
                                    }
                                }
                            }
                        }
                        .padding(.top,3)
                        .padding(.bottom, 3)
                    }
                }
            }

            Spacer()
        }
    }

    private var userMessageView: some View {
        HStack(alignment: .top) {
            Spacer()

            VStack(alignment: .trailing) {
                messageContent
                messageTimestamp
            }

            avatarImage(url: UserDefaults.standard.url(forKey: "avatarURL")?.absoluteString ?? "")
        }
    }

    private var messageContent: some View {
        return VStack{
            Text(message.content)
                .padding(5)
                .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isCurrentUser ? .white : .black)
                .cornerRadius(8)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        }
    }

    private var messageTimestamp: some View {
        Text(message.timestamp.formatted())
            .font(.caption)
            .foregroundColor(.gray)
    }

    private func avatarImage(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .foregroundColor(.gray)
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
    }
    
   
}




//struct MessageRowView: View {
//    @StateObject private var viewModel = MessageRowViewModel()
//    let message: Message
//    let isCurrentUser: Bool
//    let chat: PrivateChat
//
//    var body: some View {
//        HStack {
//            if isCurrentUser {
//                // 显示对方头像
//                AsyncImage(url: URL(string: chat.partnerAvatarURL)) { image in
//                    image.resizable().scaledToFill()
//                } placeholder: {
//                    Image(systemName: "person.circle.fill").resizable()
//                        .scaledToFill()
//                        .clipShape(Circle())
//                        .foregroundColor(.gray)
//                }
//                .frame(width: 40, height: 40)
//                .clipShape(Circle())
//
//                VStack(alignment: .leading) {
//                    Text(viewModel.updateContent(content: message.content))
//                        .padding()
//                        .background(Color.gray.opacity(0.2))
//                        .cornerRadius(8)
//                        .lineLimit(nil) // 不限制行数
//                        .fixedSize(horizontal: false, vertical: true)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                    Text(message.timestamp.formatted())
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .padding(.top, 2)
//                }
//
//                Spacer()
//            } else {
//                Spacer()
//                VStack(alignment: .trailing) {
//                    Text(viewModel.updateContent(content: message.content))
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                        .lineLimit(nil) // 不限制行数
//                        .fixedSize(horizontal: false, vertical: true)
//                        .frame(maxWidth: .infinity, alignment: .trailing)
//
//                    Text(message.timestamp.formatted())
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .padding(.top, 2)
//                }
//
//                AsyncImage(url: UserDefaults.standard.url(forKey: "avatarURL") ?? URL(filePath: "")) { image in
//                    image.resizable().scaledToFill()
//                } placeholder: {
//                    Image(systemName: "person.circle.fill").resizable()
//                        .scaledToFill()
//                        .clipShape(Circle())
//                        .foregroundColor(.gray)
//                }
//                .frame(width: 40, height: 40)
//                .clipShape(Circle())
//            }
//        }
//        .padding(isCurrentUser ? .leading : .trailing, 50)
//        .padding(.vertical, 4)
//    }
//}
