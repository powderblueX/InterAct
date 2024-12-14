//
//  CropAvatarView.swift
//  EcoStep
//
//  Created by admin on 2024/11/24.
//

import SwiftUI
import CropViewController

struct CropAvatarView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    var onCropped: (UIImage) -> Void

    func makeUIViewController(context: Context) -> CropViewController {
        let cropViewController = CropViewController(croppingStyle: .circular, image: image ?? UIImage())
        cropViewController.delegate = context.coordinator
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CropViewControllerDelegate {
        let parent: CropAvatarView

        init(_ parent: CropAvatarView) {
            self.parent = parent
        }

        func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            parent.onCropped(image)
            parent.presentationMode.wrappedValue.dismiss()
        }

        func cropViewControllerDidCancel(_ cropViewController: CropViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

