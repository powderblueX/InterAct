//
//  ActivityDetailView.swift
//  InterAct
//
//  Created by admin on 2024/11/29.
//

import SwiftUI
import Kingfisher
import MapKit
import CoreLocation

struct ActivityDetailView: View {
    @StateObject var viewModel = ActivityDetailViewModel()
    var activityId: String
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 37)  {
                ScrollView{
                    // 活动标题
                    Text(viewModel.activity?.activityName ?? "加载中...")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                        .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("发起人：    ")
                                .font(.system(size: 25, weight: .semibold))
                            HStack {
                                Text(viewModel.activity?.hostUsername ?? "加载中...")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.brown)
                                    .onTapGesture {
                                        // 获取发起人用户名位置并显示气泡
                                        viewModel.showProfileBubble.toggle()
                                    }
                                    .background(GeometryReader { geometry in
                                        Color.clear
                                            .onAppear {
                                                let frame = geometry.frame(in: .global)
                                                viewModel.profileBubblePosition = CGPoint(x: frame.midX, y: frame.minY)
                                            }
                                    })
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
                                .onTapGesture {
                                    // 点击活动地点时，显示地图
                                    viewModel.showMap = true
                                }
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
                            if (viewModel.currentUserId == viewModel.activity?.hostId) {
                                Text("您就是发起人哦！")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.blue)
                            } else {
                                VStack{
//                                    NavigationLink(destination: PrivateChatView(c: viewModel.currentUserId, recipientUserId: viewModel.activity?.hostId ?? "", privateChatId: "")) {
//
//                                        Text("私信发起人")
//                                            .font(.system(size: 20, weight: .bold))
//                                            .foregroundColor(.white)
//                                            .padding()
//                                            .frame(maxWidth: 150)
//                                            .background(.blue)
//                                            .cornerRadius(10)
//                                    }
//                                    .disabled(viewModel.currentUserId.isEmpty || ((viewModel.activity?.hostId) == nil))
                                }
                                VStack{
//                                    NavigationLink(destination: PrivateChatView(currentUserId: viewModel.currentUserId, recipientUserId: viewModel.activity?.hostId ?? "", privateChatId: "", sendParticipateIn: SendParticipateIn(activityId: activityId, activityName: viewModel.activity?.activityName ?? "加载中..."))) {
//                                        Text("我要参加")
//                                            .font(.system(size: 20, weight: .bold))
//                                            .foregroundColor(.white)
//                                            .padding()
//                                            .frame(maxWidth: 150)
//                                            .background(viewModel.checkParticipantButtonDisabled() ? .gray : .blue)
//                                            .cornerRadius(10)
//                                    }
//                                    .disabled(viewModel.checkParticipantButtonDisabled())
                                }
                            }
                        }
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .alert(isPresented: $viewModel.showParticipateAlert) {
                            Alert(
                                title: Text("提示"),
                                message: Text("您确定要参加该活动吗"),
                                primaryButton: .destructive(Text("确定")){
                                    print("请耐心等待活动发起人通过")
                                },
                                secondaryButton: .cancel(Text("取消"))
                            )
                        }
                    }
                }
                .padding()
            }
            
            // 气泡视图，显示发起人信息
            if viewModel.showProfileBubble {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        viewModel.showProfileBubble = false // 点击遮罩层关闭气泡
                    }
                VStack {
                    HStack {
                        if let avatarURL = viewModel.hostInfo?.avatarURL {
                            KFImage(avatarURL)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .padding(10)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .padding(10)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(viewModel.hostInfo?.username ?? "加载中...")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("性别：\(viewModel.hostInfo?.gender ?? "加载中...")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("经验：\(viewModel.hostInfo?.exp ?? 0)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .frame(width: 300, alignment: .leading)
                    
                    Spacer()
                }
                .onAppear{
                    viewModel.fetchHostInfo(for: viewModel.activity?.hostId ?? "")
                }
                .padding()
            }
            // 显示地图
            if viewModel.showMap, let activityLocation = viewModel.activity?.location, let myCLLocation = viewModel.myCLLocation {
                MapDetailView(activityLocation: activityLocation, myCLLocation: myCLLocation, directions: $viewModel.directions)
                    .edgesIgnoringSafeArea(.all)
            }
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
