//
//  ActivityDetailView.swift
//  InterAct
//
//  Created by admin on 2024/11/29.
//

import SwiftUI
import Kingfisher

struct ActivityDetailView: View {
    @StateObject var viewModel = ActivityDetailViewModel()
    var activityId: String
    
    var body: some View {
        
        ScrollView{
            VStack(alignment: .leading, spacing: 37)  {
                // 活动标题
                Text(viewModel.activity?.activityName ?? "加载中...")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("发起人：    ")
                            .font(.system(size: 25, weight: .semibold))
                        HStack {
                            Text(viewModel.activity?.hostUsername ?? "加载中...")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.brown)
                        }
                    }
                    
                    // 活动兴趣标签
                    // 兴趣标签
                    HStack {
                        Text("兴趣标签：")
                            .font(.system(size: 25, weight: .semibold))
                        Text(viewModel.activity?.interestTag.joined(separator: ", ") ?? "加载中...")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.purple)
                    }
                    
                    // 活动日期
                    HStack {
                        Text("活动时间：")
                            .font(.system(size: 25, weight: .semibold))
                        Text(viewModel.activity?.formattedTime ?? "加载中...")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    
                    // 参与人数
                    HStack {
                        Text("参与人数：")
                            .font(.system(size: 25, weight: .semibold))
                        Text("\(viewModel.activity?.participantIds.count ?? 0)/\(viewModel.activity?.participantsCount ?? 0)")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(viewModel.activity?.participantIds.count == viewModel.activity?.participantsCount ? .red : .blue)
                    }
                    
                    // 活动地点
                    HStack {
                        Text("活动地点：")
                            .font(.system(size: 25, weight: .semibold))
                        Text(viewModel.activity?.locationName ?? "加载中...")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                    
                    // 活动简介部分，使用 ScrollView
                    HStack{
                        Text("活动简介：")
                            .font(.system(size: 25, weight: .semibold))
                    }
                    HStack{
                        ScrollView {
                            Text(viewModel.activity?.activityDescription ?? "加载中...")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                        .frame(width: 300, height: 200, alignment: .leading)  // 固定高度，允许滚动
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack{
                        if let imageURL = viewModel.activity?.image {
                            KFImage(URL(string: imageURL.absoluteString))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .onTapGesture {
                                    // 点击头像，显示大图
                                    viewModel.isImageSheetPresented = true
                                }
                                .contextMenu {
                                    Label("保存图片", systemImage: "square.and.arrow.down")
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack {
                        NavigationLink(destination: PrivateChatView(viewModel: PrivateChatViewModel(currentUserId: viewModel.currentUserId, recipientUserId: viewModel.activity?.hostId ?? ""))) {
                            Text("私信发起人")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 150)
                                .background(.blue)
                                .cornerRadius(10)
                        }
                        .disabled(viewModel.currentUserId.isEmpty || ((viewModel.activity?.hostId) == nil))
                        
                        Button(action: {
                            // 触发参加活动操作
                            
                        }) {
                            Text("参加活动")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 150)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchActivityDetail(activityId: activityId)  // 获取活动详情
            viewModel.getCurrentId()
        }
        // 弹窗展示头像预览
        .sheet(isPresented: $viewModel.isImageSheetPresented) {
            if let imageURL = viewModel.activity?.image {
                ImagePreviewView(imageURL: imageURL, isPresented: $viewModel.isImageSheetPresented)
            }
        }
    }
}

