//
//  MessageRow.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import SwiftUI

struct MessageRow: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser {
                // 显示对方头像
                AsyncImage(url: URL(string: "https://example.com/avatar/\(message.senderId)")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill").resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(message.content)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .lineLimit(nil) // 不限制行数
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(message.timestamp.formatted())
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }
                
                Spacer()
            } else {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(message.content)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .lineLimit(nil) // 不限制行数
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(message.timestamp.formatted())
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }
                
                AsyncImage(url: UserDefaults.standard.url(forKey: "avatarURL") ?? URL(filePath: "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill").resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            }
        }
        .padding(isCurrentUser ? .leading : .trailing, 50)
        .padding(.vertical, 4)
    }
}
