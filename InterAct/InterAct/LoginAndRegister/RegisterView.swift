//
//  RegisterView.swift
//  EcoStep
//
//  Created by admin on 2024/11/19.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel = RegisterViewModel()
    @Environment(\.presentationMode) var presentationMode // 用于手动关闭当前视图
    
    private let genders = ["男", "女"]
    
    private var isFormValid: Bool {
        !viewModel.username.isEmpty &&
        !viewModel.password.isEmpty &&
        !viewModel.confirmPassword.isEmpty &&
        !viewModel.email.isEmpty
    }
    
    var body: some View {
        VStack {
            ScrollView {
                Text("注册")
                    .font(.largeTitle)
                    .padding()
                
                formField(title: "用户名：", placeholder: "请输入您的用户名", text: $viewModel.username)
                formField(title: "密码：", placeholder: "请输入您的密码", text: $viewModel.password, isSecure: true)
                formField(title: "再次确认密码：", placeholder: "请再次确认您的密码", text: $viewModel.confirmPassword, isSecure: true)
                formField(title: "电子邮箱：", placeholder: "请输入您的电子邮箱", text: $viewModel.email)
                
                // 生日选择
                VStack {
                    Text("请选择您的生日：")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 1)
                        .padding(.top, 7)
                    
                    DatePicker("生日", selection: $viewModel.birthday, displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding(.horizontal)
                        .cornerRadius(8)
                        .environment(\.locale, Locale(identifier: "zh_CN")) // 设置为中文显示
                }
                
                VStack {
                    Text("性别：")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 1)
                        .padding(.top, 7)
                    
                    Picker("Gender", selection: $viewModel.gender) {
                        ForEach(genders, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
                
                // 错误消息
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // 注册按钮
                Button(action: {
                    viewModel.register(isFormValid: isFormValid)
                }) {
                    Text(viewModel.isRegistering ? "注册中..." : "注册")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(viewModel.isRegistering)
            }
            .padding()
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("确定")) {
                        // 注册成功后关闭当前视图
                        if viewModel.alertMessage == "注册成功！" {
                            viewModel.reset() // 重置注册内容
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private func formField(title: String, placeholder: String, text: Binding<String>, isSecure: Bool = false) -> some View {
        VStack {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 5)
                .padding(.top, 7)
            
            if isSecure {
                PasswordField(password: text, placeholder: placeholder)
            } else {
                TextField(placeholder, text: text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }
        }
    }
}


#Preview {
    RegisterView(viewModel: RegisterViewModel())
}
