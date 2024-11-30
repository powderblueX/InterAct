//
//  EditAvatarViewModel.swift
//  EcoStep
//
//  Created by admin on 2024/11/24.
//

import Foundation
import SwiftUI
import LeanCloud

class EditAvatarViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var isImagePickerPresented = false
    @Published var isImageEditingPresented = false
    @Published var isUploading = false
    @Published var uploadMessage: String?
    @Published var uploadSuccess = false
    @Published var avatarURL = UserDefaults.standard.url(forKey: "avatarURL")
    
    
    // 上传图片到 LeanCloud 并关联用户
    func uploadImageToLeanCloud() {
        guard let image = selectedImage else { return }
        
        // 从 UserDefaults 获取用户名
        guard let objectId = UserDefaults.standard.string(forKey: "objectId") else {
            // TODO: 用户登出
            uploadMessage = "无法获取用户ID"
            uploadSuccess = false
            return
        }
        
        isUploading = true
        uploadMessage = nil
        
        LeanCloudService.uploadAvatar(image: image, objectId: objectId) { [weak self] success, message, avatarURL in
            DispatchQueue.main.async {
                self?.isUploading = false
                if success {
                    self?.uploadMessage = message
                    self?.uploadSuccess = true
                    self?.avatarURL = URL(string: avatarURL ?? "")
                    
                    // 保存新的头像 URL 到 UserDefaults
                    if let avatarURL = avatarURL {
                        UserDefaults.standard.set(URL(string: avatarURL), forKey: "avatarURL")
                    }
                } else {
                    self?.uploadMessage = message
                    self?.uploadSuccess = false
                }
            }
        }
    }
}
