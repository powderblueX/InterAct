//
//  RecommendedActivitiesView.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import SwiftUI
import CoreLocation

struct RecommendActivitiesView: View {
    @StateObject private var viewModel = RecommendedActivitiesViewModel()
    
    // TODO: 添加一个自己发布的活动置顶
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
                        Button(action: {
                            viewModel.searchActivities() // 执行搜索
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing, 10)
                    }
                    .padding([.leading, .trailing], 8)
                    
                    // 选择搜索方式：通过兴趣标签搜索或不使用兴趣标签
                    Picker("选择搜索方式", selection: $viewModel.useInterestFilter) {
                        Text("💡兴趣标签推荐💡").tag(true)
                        Text("📡全部推荐📡").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 7)
                    .padding(.top, 7)
                    .onChange(of: viewModel.useInterestFilter) {
                        viewModel.fetchActivities()  // 根据选择重新加载活动
                    }
                    
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
                        
                        // 显示“继续加载”按钮
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
                    .padding(.top, 5)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    .background(GeometryReader { geometry in
                        Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).maxY)
                    })
                }
                .onAppear {
                    viewModel.fetchActivities() // 加载活动
                }
                .sheet(isPresented: $viewModel.showingCreateActivityView) {
                    CreateActivityView()
                }
                
                
                
                // 圆形按钮，放置在 ZStack 中
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.showingCreateActivityView.toggle()
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

// 自定义偏移量的 Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
