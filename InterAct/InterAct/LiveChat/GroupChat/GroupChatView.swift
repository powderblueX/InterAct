//
//  GroupChatView.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

//import SwiftUI
//
//struct GroupChatView: View {
//    @StateObject private var viewModel: GroupChatViewModel
//    @State private var text: String = ""
//    
//    init(chatId: String) {
//        _viewModel = StateObject(wrappedValue: GroupChatViewModel(chatId: chatId))
//    }
//    
//    var body: some View {
//        VStack {
//            List(viewModel.messages) { message in
//                VStack(alignment: .leading) {
//                    Text(message.content)
//                        .font(.body)
//                    Text("发送时间: \(message.timestamp, formatter: dateFormatter)")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//            }
//            
//            HStack {
//                TextField("输入消息", text: $text)
//                    .padding()
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                
//                Button(action: {
//                    viewModel.newMessage = text
//                    viewModel.sendMessage()
//                }) {
//                    Text("发送")
//                        .padding()
//                }
//            }
//            .padding()
//        }
//        .navigationBarTitle("群聊", displayMode: .inline)
//    }
//}
