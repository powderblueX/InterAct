//
//  CameraView.swift
//  EcoStep
//
//  Created by admin on 2024/11/20.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: [UIImage]
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        // 判断相机是否可用
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    picker.sourceType = .camera
        } else {
            // 如果相机不可用，弹出一个提醒框
            DispatchQueue.main.async {
                context.coordinator.showCameraUnavailableAlert()
            }
            picker.sourceType = .photoLibrary // 作为备用，默认显示相册
        }
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage.append(image)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        // 显示相机不可用的提醒框
        func showCameraUnavailableAlert() {
            DispatchQueue.main.async { // 确保在主线程上执行
                guard let rootViewController = self.findRootViewController() else {
                    print("无法找到根视图控制器")
                    return
                }
                let alert = UIAlertController(
                    title: "相机不可用",
                    message: "当前设备不支持相机，是否切换到相册？",
                    preferredStyle: .alert
                )

                // 提供切换到相册的选项
                alert.addAction(UIAlertAction(title: "使用相册", style: .default) { _ in
                    let picker = UIImagePickerController()
                    picker.sourceType = .photoLibrary
                    picker.delegate = self
                    rootViewController.present(picker, animated: true)
                })

                // 提供取消的选项
                alert.addAction(UIAlertAction(title: "取消", style: .cancel) { _ in
                    self.parent.dismiss()
                })

                rootViewController.present(alert, animated: true)
            }
        }
        
        // 找到根视图控制器
        private func findRootViewController() -> UIViewController? {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else {
                return nil
            }
            return window.rootViewController
        }
    }
}

