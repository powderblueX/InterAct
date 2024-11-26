//
//  LoginView.swift
//  EcoStep
//
//  Created by admin on 2024/11/23.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("登录")
                .font(.largeTitle)
                .bold()
            
            Text("用户名：")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 7)
            TextField("请输入您的用户名", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.horizontal)
            
            Text("密码：")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 7)
            PasswordField(password: $viewModel.password, placeholder: "请输入您的密码")
            
            if viewModel.isLogining {
                ProgressView("登录中...") // 显示加载指示器
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                Button(action: {
                    viewModel.login()
                }) {
                    Text("登录")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            NavigationLink(destination: RegisterView(viewModel: RegisterViewModel())) {
                Text("没有账号？点这里注册！")
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel())
}
