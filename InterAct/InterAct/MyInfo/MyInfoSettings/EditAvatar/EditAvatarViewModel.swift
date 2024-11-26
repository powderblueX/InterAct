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

    
    /// 上传图片到 LeanCloud 并关联用户
    func uploadImageToLeanCloud() {
        guard let image = selectedImage else { return }
        
        // 从 UserDefaults 获取用户名
        guard let objectId = UserDefaults.standard.string(forKey: "objectId") else {
            uploadMessage = "无法获取用户ID"
            uploadSuccess = false
            return
        }
        
        isUploading = true
        uploadMessage = nil
        
        // 将 UIImage 转换为 JPEG 数据
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            uploadMessage = "图片处理失败"
            uploadSuccess = false
            isUploading = false
            return
        }
        
        // 创建 LeanCloud 文件对象
        let file = LCFile(payload: .data(data: imageData))
        
        file.save { result in
            DispatchQueue.main.async {
                self.isUploading = false
                
                switch result {
                case .success:
                    self.uploadMessage = "头像上传成功"
                    self.uploadSuccess = true
                    
                    // 使用 objectId 查询用户
                    let query = LCQuery(className: "_User")
                    query.whereKey("objectId", .equalTo(objectId))
                    query.find { result in
                        switch result {
                        case .success(let users):
                            if let currentUser = users.first {
                                // 用户查询成功，更新头像 URL
                                if let fileURL = file.url?.value {
                                    // 强制将 HTTP URL 替换为 HTTPS
                                    let secureURL = fileURL.replacingOccurrences(of: "http://", with: "https://")
                                    do {
                                        // 使用 try 语句调用 set 方法，捕获可能的错误
                                        try currentUser.set("avatarURL", value: secureURL)
                                        
                                        currentUser.save { saveResult in
                                            switch saveResult {
                                            case .success:
                                                print("头像 URL 成功保存到用户表中")
                                            case .failure(let error):
                                                print("头像 URL 保存失败: \(error.localizedDescription)")
                                                self.uploadSuccess = false
                                            }
                                        }
                                    } catch {
                                        self.uploadMessage = "更新头像 URL 失败: \(error.localizedDescription)"
                                        self.uploadSuccess = false
                                    }
                                }
                            } else {
                                self.uploadMessage = "未找到当前用户"
                                self.uploadSuccess = false
                            }
                        case .failure(let error):
                            self.uploadMessage = "查询用户失败: \(error.localizedDescription)"
                            self.uploadSuccess = false
                        }
                    }
                case .failure(let error):
                    self.uploadMessage = "上传失败: \(error.localizedDescription)"
                    self.uploadSuccess = false
                }
            }
        }
    }
}
