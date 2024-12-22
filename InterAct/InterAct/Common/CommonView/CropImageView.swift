//
//  CropImageView.swift
//  InterAct
//
//  Created by admin on 2024/12/9.
//

import SwiftUI
import CropViewController

struct CropImageView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    var onCropped: (UIImage) -> Void

    func makeUIViewController(context: Context) -> CropViewController {
        let cropViewController = CropViewController(croppingStyle: .default, image: image ?? UIImage())
        cropViewController.delegate = context.coordinator
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CropViewControllerDelegate {
        let parent: CropImageView

        init(_ parent: CropImageView) {
            self.parent = parent
        }

        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            parent.onCropped(image)
            parent.presentationMode.wrappedValue.dismiss()
        }

        func cropViewControllerDidCancel(_ cropViewController: CropViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}