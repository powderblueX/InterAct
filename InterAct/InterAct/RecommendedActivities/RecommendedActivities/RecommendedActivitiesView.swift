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
    @State private var isAnimating = false // 用于控制文字跳动动画
    @State private var shimmerOffset: CGFloat = -200 // 控制闪烁位置

    var body: some View {
        NavigationView {
            ZStack {
                DynamicBackgroundView()
                    .ignoresSafeArea()
                VStack {
                    // 页面标题
                    HStack {
                        Text("🌈 ")
                        Text("为你推荐")
                            .gradientForeground(colors: [.red, .orange, .yellow, .green, .cyan, .blue, .purple])
                        Text(" 🌟")
                    }
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .scaleEffect(isAnimating ? 1.5 : 1.0) // 缩放动画
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            isAnimating.toggle()
                        }
                    }
                    // 搜索栏
                    HStack {
                        TextField("搜索活动...", text: $viewModel.searchText)
                            .padding(.leading, 10)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            .shadow(radius: 10)
                            .border(Color(UIColor.systemBackground))
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
                    if viewModel.isLoading {
                        ProgressView("加载中...")
                    } else {
                        // 活动列表
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                if viewModel.useInterestFilter && !viewModel.userInterest.contains("无🚫"){
                                    ForEach(viewModel.activitiesByInterest, id: \.id) { activity in
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
                                } else {
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
                            }
                            .padding(.top, 10)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                            
                            if viewModel.hasMoreData && !viewModel.isLoadingMore {
                                Button(action: {
                                    viewModel.loadMoreActivities(useInterestFilter: viewModel.useInterestFilter && !viewModel.userInterest.contains("无🚫"))
                                }) {
                                    Text("-------继续加载-------")
                                        .foregroundStyle(Color(UIColor.systemBackground))
                                        .padding()
                                }
                                .padding(.bottom,150)
                            } else if !viewModel.hasMoreData {
                                Text("-------已加载全部活动-------")
                                    .foregroundStyle(Color(UIColor.systemBackground))
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
                        Button(action:{
                            viewModel.updateStatus()
                        }) {
                            Circle()
                                .fill(.green)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "arrow.trianglehead.clockwise.rotate.90")
                                        .foregroundColor(.white)
                                        .font(.title)
                                )
                                .shadow(radius: 10)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .bottomLeading)
                        
                        Spacer()
                        Button(action: {
                            viewModel.showingCreateActivityView.toggle()
                        }) {
                            Circle()
                                .fill(.blue)
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
