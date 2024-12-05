//
//  MessageRow.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import SwiftUI

struct MessageRowView: View {
    let message: Message
    let isCurrentUser: Bool
    let chat: PrivateChat

    var body: some View {
        HStack {
            if isCurrentUser {
                userMessageView
            } else {
                partnerMessageView
            }
        }
        .padding(isCurrentUser ? .leading : .trailing, 10)
        .padding(isCurrentUser ? .trailing : .leading, 40)
        .padding(.vertical, 4)
    }

    private var userMessageView: some View {
        HStack {
            // 显示对方头像
            avatarImage(url: chat.partnerAvatarURL)
            
            VStack(alignment: .leading) {
                messageContent
                messageTimestamp
            }

            Spacer()
        }
    }

    private var partnerMessageView: some View {
        HStack {
            Spacer()

            VStack(alignment: .trailing) {
                messageContent
                messageTimestamp
            }

            avatarImage(url: UserDefaults.standard.url(forKey: "avatarURL")?.absoluteString ?? "")
        }
    }

    private var messageContent: some View {
        Text(message.content)
            .padding(5)
            .background(isCurrentUser ? Color.gray.opacity(0.2) : Color.blue)
            .foregroundColor(isCurrentUser ? .black : .white)
            .cornerRadius(8)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: isCurrentUser ? .leading : .trailing)
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
//                    Text(message.content)
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
//                    Text(message.content)
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
