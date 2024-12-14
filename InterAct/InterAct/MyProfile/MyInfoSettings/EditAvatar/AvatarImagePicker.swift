//
//  AvatarImagePicker.swift
//  EcoStep
//
//  Created by admin on 2024/11/24.
//

import Foundation
import SwiftUI
import CropViewController

enum AvatarImagePicker {
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var selectedImage: UIImage?
        var onImagePicked: () -> Void
        @Binding var isEditingPresented: Bool

        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = .photoLibrary
            return picker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            let parent: ImagePicker

            init(_ parent: ImagePicker) {
                self.parent = parent
            }

            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                picker.dismiss(animated: true)
                if let image = info[.originalImage] as? UIImage {
                    // 将选中的图片传递给裁剪视图
                    self.parent.selectedImage = image
                    self.parent.isEditingPresented = true
                    self.parent.onImagePicked()
                }
            }

            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true)
            }
        }
    }
}
