//
//  AvatarPreviewViewModel.swift
//  EcoStep
//
//  Created by admin on 2024/11/24.
//

import SwiftUI
import Kingfisher

class AvatarPreviewViewModel: ObservableObject {
    @Published var showSaveConfirmation = false
    @Published var saveSuccessMessage: String? = nil

    func saveImageToPhotos(from url: URL) {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let imageResult):
                UIImageWriteToSavedPhotosAlbum(imageResult.image, nil, nil, nil)
                DispatchQueue.main.async {
                    self.saveSuccessMessage = "图片已成功保存到相册！"
                    self.autoDismissSuccessMessage()
                }
            case .failure(let error):
                print("保存失败：\(error.localizedDescription)")
            }
        }
    }
    
    private func autoDismissSuccessMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.saveSuccessMessage = nil
        }
    }
}

