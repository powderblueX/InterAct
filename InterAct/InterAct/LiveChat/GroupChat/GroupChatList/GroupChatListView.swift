//
//  GroupChatView.swift
//  InterAct
//
//  Created by admin on 2024/12/6.
//

import SwiftUI
import LeanCloud

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
                        }
                        
                        Spacer()

                        NavigationLink(destination: GroupChatView(groupChat: chat)) {
                        }
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



