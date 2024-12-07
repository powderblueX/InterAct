//
//  GroupMessageRowView.swift
//  InterAct
//
//  Created by admin on 2024/12/7.
//

import SwiftUI

struct GroupMessageRowView: View {
    @StateObject private var viewModel = GroupMessageRowViewModel()
    @State var message: Message
    let isCurrentUser: Bool
    let senderInfo: ParticipantInfo

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
    }

    private var partnerMessageView: some View {
        HStack(alignment: .top) {
            NavigationLink(destination: UserProfileView(userInfo: senderInfo)){
                avatarImage(url: senderInfo.avatarURL?.absoluteString ?? "")
            }
            
            VStack(alignment: .leading) {
                Text(senderInfo.username)
                    .font(.subheadline)
                messageContent
                messageTimestamp
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
