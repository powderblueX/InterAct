//
//  MyInfoView.swift
//  InterAct
//
//  Created by admin on 2024/11/23.
//

import SwiftUI
import Kingfisher

struct MyProfileView: View {
    @StateObject private var viewModel = MyProfileViewModel()
    @State private var isAvatarSheetPresented = false // 控制头像预览弹窗
    @State private var showSaveImageAlert = false // 控制保存提示

    var body: some View {
        NavigationView {
            ZStack{
                DynamicBackgroundView()
                    .ignoresSafeArea()
                Group {
                    if viewModel.isLoading {
                        loadingView
                    } else if let userInfo = viewModel.userInfo {
                        contentView(userInfo: userInfo)
                    } else if let errorMessage = viewModel.errorMessage {
                        errorView(errorMessage: errorMessage)
                    }
                }
                .navigationBarTitle("我的信息", displayMode: .inline)
                .navigationBarItems(trailing: settingsButton)
                .onAppear {
                    viewModel.fetchUserInfo()
                }
            }
        }
        .sheet(isPresented: $isAvatarSheetPresented) {
            if let avatarURL = viewModel.userInfo?.avatarURL {
                AvatarPreviewView(imageURL: avatarURL, isPresented: $isAvatarSheetPresented)
            }
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("加载中...")
                .progressViewStyle(CircularProgressViewStyle())
            Spacer()
        }
    }

    private func contentView(userInfo: MyProfileModel) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                avatarSection(userInfo: userInfo)
                basicInfoSection(userInfo: userInfo)
                userDetailsSection(userInfo: userInfo)
                activityPickerSection

                if viewModel.MeAndActivities {
                    HistoryActivitiesView()
                        .frame(height: 500)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                }
            }
            .padding(.horizontal)
        }
    }

    private func errorView(errorMessage: String) -> some View {
        VStack {
            Spacer()
            Text("加载失败")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.red)
            Text(errorMessage)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
            Button(action: viewModel.fetchUserInfo) {
                Text("重试")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Spacer()
        }
    }

    private var settingsButton: some View {
        NavigationLink(destination: SettingsView(userInfo: $viewModel.userInfo)) {
            Image(systemName: "gearshape")
                .imageScale(.large)
                .foregroundColor(.blue)
        }
    }

    private func avatarSection(userInfo: MyProfileModel) -> some View {
        VStack {
            if let avatarURL = userInfo.avatarURL {
                KFImage(URL(string: avatarURL.absoluteString))
                    .placeholder {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                    .onTapGesture {
                        isAvatarSheetPresented = true
                    }
                    .contextMenu {
                        Button(action: {
                            showSaveImageAlert = true
                        }) {
                            Label("保存图片", systemImage: "square.and.arrow.down")
                        }
                    }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray)
            }
        }
    }

    private func basicInfoSection(userInfo: MyProfileModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(userInfo.username)
                .font(.title)
                .fontWeight(.bold)
            Text(userInfo.email)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("性别：\(userInfo.gender)")
                .font(.body)
            Text("生日：\(userInfo.birthday, style: .date)")
                .font(.body)
                .environment(\.locale, Locale(identifier: "zh_CN"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func userDetailsSection(userInfo: MyProfileModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("我的兴趣标签：\(userInfo.interest.joined(separator: "、"))")
                .font(.body)
            Text("我的声望：\(userInfo.exp >= 0 ? "+\(userInfo.exp)" : "\(userInfo.exp)")")
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var activityPickerSection: some View {
        Picker("查看信息", selection: $viewModel.MeAndActivities) {
            Text("↓  🎗️我参与的活动🎗️  ↓").tag(true)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}
