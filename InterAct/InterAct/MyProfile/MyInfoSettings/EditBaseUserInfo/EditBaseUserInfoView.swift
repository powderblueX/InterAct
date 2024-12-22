//
//  EditUsernameEmailView.swift
//  EcoStep
//
//  Created by admin on 2024/11/24.
//

import SwiftUI

struct EditBaseUserInfoView: View {
    @Binding var userInfo: MyProfileModel?
    @StateObject private var viewModel = EditBaseUserInfoViewModel()
    private let genders = ["男", "女"]
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("用户名")) {
                TextField("用户名", text: $viewModel.newUsername)
                    .autocapitalization(.none)
            }
            
            Section(header: Text("生日")) {
                DatePicker("生日", selection: $viewModel.birthday, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "zh_CN")) // 设置中文
            }

            Section(header: Text("性别")) {
                Picker("性别", selection: $viewModel.gender) {
                    ForEach(genders, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Button(action: {
                viewModel.saveChanges { success in
                    if success {
                        // 更新绑定的数据
                        userInfo?.username = viewModel.newUsername
                        userInfo?.birthday = viewModel.birthday
                        userInfo?.gender = viewModel.gender
                    }
                }
            }) {
                Text("保存更改")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(viewModel.isButtonDisabled ? Color.gray : Color.blue)
                    .cornerRadius(8)
            }
            .disabled(viewModel.isButtonDisabled)
        }
        .onAppear {
            // 初始化输入框内容
            viewModel.initializeFields(with: userInfo)
        }
        .onChange(of: viewModel.isUsernameEmailUpdated) {
            if viewModel.isUsernameEmailUpdated {
                presentationMode.wrappedValue.dismiss() // 返回上一级界面
            }
        }
        .alert(item: $viewModel.alertType) { alertType in
            Alert(
                title: Text(alertType.title),
                message: Text(alertType.message),
                dismissButton: .default(Text("好的"), action: {
                    if case .success = alertType {
                        presentationMode.wrappedValue.dismiss() // 成功后返回上一级界面
                    }
                })
            )
        }
        .navigationTitle("修改用户基本信息")
    }
}
