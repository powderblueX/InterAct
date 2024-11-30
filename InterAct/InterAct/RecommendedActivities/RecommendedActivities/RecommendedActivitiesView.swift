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
        NavigationView {
            ZStack {
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
                                    destination: ActivityDetailView(activityId: activity.id),
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
                }
                .onAppear {
                    viewModel.fetchActivities() // 加载活动
                }
                .sheet(isPresented: $showingCreateActivityView) {
                    CreateActivityView()
                }
                
                // 圆形按钮，放置在 ZStack 中
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
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
                }
                .padding()
            }
        }
    }
}

