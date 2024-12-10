//
//  SettingsView.swift
//  InterAct
//
//  Created by admin on 2024/11/23.
//

import SwiftUI

struct SettingsView: View {
    @Binding var userInfo: MyInfoModel?
    @StateObject private var viewModel = SettingsViewModel()
    let iconOptions = [
            ("默认图标", nil),
            ("深色模式图标", "InterActDarkIcon"),
            ("节日图标", "InterActHolidayIcon")
        ]

    var body: some View {
        List {
            Section(header: Text("个人信息修改")) {
                NavigationLink(destination: EditBaseUserInfoView(userInfo: $userInfo)) {
                    Text("修改基础信息")
                }

                NavigationLink(destination: EditAvatarView()) {
                    Text("修改头像")
                }
                
                NavigationLink(destination: EditInteresView(userInfo: $userInfo)) {
                    Text("修改兴趣标签")
                }
            }

            Section(header: Text("账户安全")) {
                NavigationLink(destination: ChangePasswordView()) {
                    Text("修改密码")
                }
            }
            
            Section(header: Text("外观设置")) {
                Toggle(isOn: $viewModel.isDarkMode) {
                    Text("深色模式")
                }
                .onChange(of: viewModel.isDarkMode) {
                    // 更新用户界面样式
                    viewModel.updateAppearance()
                }
                Section(header: Text("应用外观")) {
                    ForEach(iconOptions, id: \.1) { option in
                        Button(option.0) {
                            viewModel.switchToIcon(named: option.1)
                        }
                    }
                }
            }
            

            
            Section(header: Text("关于我们")) {
                Text("版本：1.0.0")
            }
            
            // 退出登录
            Button("退出登录") {
                viewModel.showLogoutAlert = true // 显示退出确认弹窗
            }
            .foregroundColor(.red)
        }
        .navigationTitle("设置")
        .alert(isPresented: $viewModel.showLogoutAlert) {
            Alert(
                title: Text("确认退出"),
                message: Text("你确定要退出登录吗？"),
                primaryButton: .destructive(Text("退出")) {
                    viewModel.logout() // 执行退出登录操作
                },
                secondaryButton: .cancel(Text("取消"))
            )
        }
    }
}


