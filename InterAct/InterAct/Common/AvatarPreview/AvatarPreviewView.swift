//
//  AvatarPreviewView.swift
//  EcoStep
//
//  Created by admin on 2024/11/24.
//

import SwiftUI
import Kingfisher

struct AvatarPreviewView: View {
    let imageURL: URL
    @Binding var isPresented: Bool
    @StateObject private var viewModel = AvatarPreviewViewModel()

    var body: some View {
        ZStack {
            // 背景颜色
            Color.black.edgesIgnoringSafeArea(.all)
            
            // 大图展示
            KFImage(imageURL)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    // 点击大图关闭预览
                    isPresented = false
                }
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                    }
                    .padding()
                }
                Spacer()
            }
            
            // 保存按钮
            VStack {
                Spacer()
                Button(action: {
                    viewModel.showSaveConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("保存图片")
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .foregroundColor(.black)
                    .clipShape(Capsule())
                }
                .padding(.bottom, 40)
            }
        }
        .alert(isPresented: $viewModel.showSaveConfirmation) {
            Alert(
                title: Text("提示"),
                message: Text("是否保存图片到相册？"),
                primaryButton: .default(Text("保存")) {
                    viewModel.saveImageToPhotos(from: imageURL)
                },
                secondaryButton: .cancel(Text("取消"))
            )
        }
        .overlay(
            // 保存成功提示，自动消散
            Group {
                if let successMessage = viewModel.saveSuccessMessage {
                    Text(successMessage)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .transition(.opacity)
                        .animation(.easeInOut, value: viewModel.saveSuccessMessage)
                }
            },
            alignment: .top
        )
    }
}
