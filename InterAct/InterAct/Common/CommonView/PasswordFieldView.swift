//
//  PasswordFieldView.swift
//  EcoStep
//
//  Created by admin on 2024/11/24.
//

import SwiftUI

struct PasswordField: View {
    @Binding var password: String  // 绑定密码
    @State private var isPasswordVisible = false // 控制是否可见

    var placeholder: String = "请输入密码"

    var body: some View {
        HStack {
            if isPasswordVisible {
                // 如果密码可见，使用 TextField 显示
                TextField(placeholder, text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            } else {
                // 如果密码隐藏，使用 SecureField 显示
                SecureField(placeholder, text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }

            // 小眼睛按钮
            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                    .foregroundColor(.gray)
            }
        }
    }
}

