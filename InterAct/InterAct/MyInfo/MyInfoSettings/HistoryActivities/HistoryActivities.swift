//
//  ActivitiesIParticipantin.swift
//  InterAct
//
//  Created by admin on 2024/12/11.
//

import SwiftUI

struct HistoryActivitiesView: View {
    @StateObject var viewModel = HistoryActivitiesViewModel()
    
    var body: some View {
        ScrollView() {
            if !viewModel.activities.isEmpty {
                ForEach(viewModel.activities, id: \.id){ activity in
                    HStack{
                        VStack(alignment: .leading, spacing: 5) {
                            Text(activity.activityName)
                                .font(.title3)
                                .lineLimit(1)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("地点：\(activity.locationName)")
                                .font(.subheadline)
                                .lineLimit(1)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("时间: \(activity.activityTime.formatted(.dateTime))")
                                .font(.footnote)
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        NavigationLink(destination: HistoryActivityDetailView(historyActivity: activity)){
                            Image(systemName: "chevron.forward.circle.fill")
                                .foregroundStyle(.yellow)
                                .font(.title)
                        }
                    }
                    .padding() // 增加内边距
                    .frame(maxWidth: .infinity) // 保证整个块的宽度一致
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2) // 添加阴影效果以美化
                    .padding(.horizontal) // 增加外边距，避免贴边
                }
            } else {
                Text("您还没有参加活动哦！")
                    .foregroundColor(.mint)
                    .padding()
            }
            if viewModel.hasMoreData && !viewModel.isLoadingMore {
                Button(action: {
                    viewModel.loadMoreActivities()
                }) {
                    Text("-------继续加载-------")
                        .foregroundColor(.blue)
                        .padding()
                }
                .padding(.bottom,150)
            } else if !viewModel.hasMoreData {
                Text("-------已加载全部活动-------")
                    .foregroundColor(.blue)
                    .padding()
            }
            
            if viewModel.isLoadingMore {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.top, 20)
            }
        }
        .onAppear{
            viewModel.fetchAllActivitiesIParticipatein(page: viewModel.currentPage)
        }
    }
}
