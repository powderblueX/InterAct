//
//  GroupChatManageView.swift
//  InterAct
//
//  Created by admin on 2024/12/7.
//

import SwiftUI

struct GroupChatManageView: View {
    @StateObject var viewModel = GroupChatManageViewModel()
    @State var groupChat: GroupChatList
    @State var participantsInfo: [ParticipantInfo]
    @State var currentUserId: String
    
    let rows = [GridItem(.adaptive(minimum: 80))] // 自适应网格布局
    
    init(groupChat: GroupChatList, participantsInfo: [ParticipantInfo], currentUserId: String) {
        self.groupChat = groupChat
        self.participantsInfo = participantsInfo
        self.currentUserId = currentUserId
    }
    
    // TODO: 管理
    var body: some View {
        VStack{
            ScrollView{
                // 显示群聊信息
                NavigationLink(destination: ActivityDetailView(activityId: groupChat.activityId)){
                    Text("\(groupChat.activityName)")
                        .font(.title)
                        .padding()
                        .bold()
                        .foregroundStyle(.orange)
                }
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading){
                    HStack {
                        Text("群成员/活动成员(\(participantsInfo.count)):")
                            .font(.title3)
                            .foregroundStyle(.blue)
                            .bold()
                        Spacer()
                        if groupChat.hostId == currentUserId {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundStyle(.red) // 踢出成员
                                .font(.title)
                        }
                    }
                    
                    ScrollView{
                        LazyHGrid(rows: rows, alignment: .top, spacing: 16) {
                            ForEach(participantsInfo, id: \.id) { participantInfo in
                                NavigationLink(destination: UserProfileView(userInfo: participantInfo)){
                                    VStack(alignment: .center){
                                        AsyncImage(url: participantInfo.avatarURL) { image in
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
                                        
                                        Text(participantInfo.username)
                                            .font(.system(size: 14))
                                            .bold()
                                            .frame(maxWidth: .infinity)
                                            .cornerRadius(8)
                                            .lineLimit(1)
                                            .foregroundStyle(participantInfo.id == groupChat.hostId ? .brown : .yellow)
                                    }
                                    .frame(width: 60)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(width: 350, height: 200)
                    .shadow(radius: 10)
                    .border(Color(UIColor.systemBackground))
                    .frame(maxWidth: .infinity)
                }
                .padding(7)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2) // 添加阴影效果以美化
                .padding(.horizontal) // 增加外边距，避免贴边
                
                VStack {
                    if viewModel.activityIsDone{
                        Text ("活动已结束")
                            .font(.title2)
                            .foregroundStyle(.green)
                    } else {
                        Text ("活动未结束")
                            .font(.title2)
                            .foregroundStyle(.cyan)
                    }
                }
                .padding(.top, 37)
                .background(Color(UIColor.secondarySystemBackground))
                .padding(.horizontal)
                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                .cornerRadius(8)
                
                VStack{
                    if groupChat.hostId == currentUserId{
                        Button(action: {
                            viewModel.markActivityAsDone(userId: currentUserId, activityId: groupChat.activityId)
                        }){
                            VStack{
                                Text("结束活动")
                                    .font(.subheadline)
                                    .padding(.bottom, 2)
                                Text("🎉🥳 活动完结 🥳🎉")
                                    .font(.caption2)
                            }
                            .foregroundStyle(.white)
                            .padding(5)
                            .frame(maxWidth: 280)
                            .background(.red)
                            .cornerRadius(10)
                        }
                        if viewModel.activityIsDone {
                            Button(action: {
                                
                            }){
                                VStack{
                                    Text("结束群聊/活动")
                                        .font(.subheadline)
                                        .padding(.bottom, 2)
                                    Text("🤪活动完结,解散群聊🤪")
                                        .font(.caption2)
                                }
                                .foregroundStyle(.white)
                                .padding(5)
                                .frame(maxWidth: 280)
                                .background(.red)
                                .cornerRadius(10)
                            }
                        } else {
                            Button(action: {
                                
                            }){
                                VStack{
                                    Text("删除群聊/活动")
                                        .font(.subheadline)
                                        .padding(.bottom, 2)
                                    Text("群聊/活动 将从您的记录中消失，并且会扣除您1声望哦")
                                        .font(.caption2)
                                }
                                .foregroundStyle(.white)
                                .padding(5)
                                .frame(maxWidth: 280)
                                .background(.red)
                                .cornerRadius(10)
                            }
                        }
                    } else {
                        if viewModel.isProcessing {
                            ProgressView("正在处理...")
                        } else {
                            Button(action: {
                                viewModel.exitGroupAndActivity(conversationId: groupChat.groupChatId, userId: currentUserId, activityId: groupChat.activityId)
                            }){
                                VStack{
                                    if viewModel.activityIsDone {
                                        Text("退出群聊/活动")
                                            .font(.subheadline)
                                            .padding(.bottom, 2)
                                        Text("😗群聊/活动 将不会从您的记录中消失😗")
                                            .font(.caption2)
                                    } else {
                                        Text("中途退出群聊/活动")
                                            .font(.subheadline)
                                            .padding(.bottom, 2)
                                        Text("群聊/活动 将从您的记录中消失，并且会扣除您3声望哦")
                                            .font(.caption2)
                                    }
                                }
                                .foregroundStyle(.white)
                                .padding(5)
                                .frame(maxWidth: 280)
                                .background(.red)
                                .cornerRadius(10)
                            }
                            .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                                Alert(title: Text("错误"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("确定")))
                            }
                        }
                    }
                }
                .padding(.top, 43)
            }
            .onAppear{
                viewModel.loadActivityStatus(activityId: groupChat.activityId)
            }
        }
    }
}
