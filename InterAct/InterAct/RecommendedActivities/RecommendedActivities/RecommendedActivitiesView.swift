//
//  RecommendedActivitiesView.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import SwiftUI
import CoreLocation

struct RecommendActivities: View {
    
    @StateObject private var viewModel = RecommendedActivitiesViewModel()

    @State private var showingCreateActivityView: Bool = false
    
    // TODO: 添加一个是否通过标签来选择 添加一个自己发布的活动置顶
    var body: some View {
        NavigationView{
            VStack {
                // 页面标题
                Text("为你推荐")
                    .font(.largeTitle)
                    .padding()
                
                // 搜索栏
                HStack {
                    TextField("搜索活动...", text: $viewModel.searchText)
                        .padding(.leading, 10)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .onChange(of: viewModel.searchText) {
                            viewModel.searchActivities() // 搜索活动
                        }
                    
                    Button(action: {
                        viewModel.searchActivities() // 执行搜索
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 10)
                }
                .padding([.leading, .trailing], 16)
                
                // 活动列表
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.activities, id: \.id) { activity in
                            NavigationLink(
                                destination: ActivityDetailView(activity: activity),
                                label: {
                                    ActivityCardView(activity: activity)
                                        .frame(height: 150)
                                        .padding(.top, 7)
                                }
                            )
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top, 10)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                }
                .padding(.top, 20)
                .padding(.leading, 15)
                .padding(.trailing, 15)
                
                
                // 圆形按钮
                Button(action: {
                    showingCreateActivityView.toggle()
                }) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.title)
                        )
                        .shadow(radius: 10)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)
            }
            
            .onAppear {
                viewModel.fetchActivities() // 加载活动
            }
            .sheet(isPresented: $showingCreateActivityView) {
                CreateActivityView()
            }
        }
    }
}

// 活动卡片视图
struct ActivityCardView: View {
    @StateObject private var viewModel = RecommendedActivitiesViewModel()
    
    var activity: Activity
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: activity.activityTime)
    }
    
    var body: some View {
        VStack {
            Text(activity.activityName)
                .font(.headline)
                .padding(.top, 5)
            
            Text(formattedDate)
                .font(.subheadline)
                .lineLimit(3)
                .padding(.top, 2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .center)
                .environment(\.locale, Locale(identifier: "zh_CN"))
            
            Text("标签: \(activity.interestTag.joined(separator: ", "))")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 2)
            
            Text("参与人数: \(activity.participantIds.count)/\(activity.participantsCount)")
                .font(.footnote)
                .foregroundColor(viewModel.getparticipantsCountColor(isFull: activity.participantIds.count == activity.participantsCount))
                .padding(.top, 1)
            
            Text("离你 \(viewModel.LocationDistance(location: activity.location)) km")
                .font(.footnote)
                .padding(.top, 1)
                .foregroundColor(.brown)
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}




