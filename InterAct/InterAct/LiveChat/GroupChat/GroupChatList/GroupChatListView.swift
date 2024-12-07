//
//  GroupChatView.swift
//  InterAct
//
//  Created by admin on 2024/12/6.
//

import SwiftUI
import LeanCloud

// TODO: 更新列表
struct GroupChatListView: View {
    @StateObject private var viewModel = GroupChatListViewModel()
    
    var body: some View {
        NavigationView {
            VStack{
                List(viewModel.groupChats, id: \.activityId) { chat in
                    HStack {
                        Image(systemName: "person.3")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)

                        VStack(alignment: .leading) {
                            Text(chat.activityName)
                                .font(.headline)
                                .lineLimit(1)
                            Text("\(viewModel.formatDate(chat.lmDate))")
                                .font(.subheadline)
                                .environment(\.locale, Locale(identifier: "zh_CN"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)  
                        
                        NavigationLink(destination: GroupChatView(groupChat: chat)) {
                            
                        }
                        .frame(maxWidth: 30, alignment: .trailing)
                    }
                }
            }
            .navigationTitle("群聊列表")
            .onAppear {
                viewModel.fetchGroupChats()
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

