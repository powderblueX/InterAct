//
//  EditInterestView.swift
//  InterAct
//
//  Created by admin on 2024/11/26.
//

import SwiftUI

struct EditInteresView: View {
    @Binding var userInfo: MyInfoModel?
    @StateObject private var viewModel = EditIntereViewModel()
    private let genders = ["男", "女"]
    
    let columns = [GridItem(.adaptive(minimum: 80))] // 自适应网格布局
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.interestTags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 14))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.selectedInterests.contains(tag) ? Color.blue.opacity(0.8) : Color.gray.opacity(0.2))
                            .foregroundColor(viewModel.selectedInterests.contains(tag) ? .white : .black)
                            .cornerRadius(8)
                            .onTapGesture {
                                viewModel.toggleInterest(tag)
                            }
                    }
                }
                .padding()
            }
            
            Button(action: {
                viewModel.saveChanges { success in
                    if success {
                        presentationMode.wrappedValue.dismiss()
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
            .disabled(viewModel.isButtonDisabled) // 禁用按钮逻辑
            .padding()
        }
        .onAppear {
            // 初始化输入框内容
            viewModel.initializeFields(with: userInfo)
        }
//        .onChange(of: viewModel.isUsernameEmailUpdated) {
//            if viewModel.isUsernameEmailUpdated {
//                presentationMode.wrappedValue.dismiss() // 返回上一级界面
//            }
//        }
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
        .navigationTitle("选择兴趣标签")
    }
}

