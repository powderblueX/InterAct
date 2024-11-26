//
//  UploadAvatarView.swift
//  EcoStep
//
//  Created by admin on 2024/11/24.
//

import SwiftUI

struct EditAvatarView: View {

    
    @StateObject private var viewModel = EditAvatarViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .foregroundColor(.gray) // 默认头像颜色
                }
                
                Button("选择头像") {
                    viewModel.isImagePickerPresented = true
                }
                .padding()
                
                if viewModel.isUploading {
                    ProgressView("正在上传...")
                } else if let message = viewModel.uploadMessage {
                    Text(message)
                        .foregroundColor(viewModel.uploadSuccess ? .green : .red)
                }
            }
            .navigationTitle("编辑头像")
            .sheet(isPresented: $viewModel.isImagePickerPresented) {
                AvatarImagePicker.ImagePicker(
                    selectedImage: $viewModel.selectedImage,
                    onImagePicked: {
                        viewModel.isImageEditingPresented = true
                    },
                    isEditingPresented: $viewModel.isImageEditingPresented
                )
            }
            .fullScreenCover(isPresented: $viewModel.isImageEditingPresented) {
                if viewModel.selectedImage != nil {
                    CropImageView(image: $viewModel.selectedImage) { croppedImage in
                        viewModel.selectedImage = croppedImage
                        viewModel.uploadImageToLeanCloud()
                    }
                }
            }
        }
    }
}
