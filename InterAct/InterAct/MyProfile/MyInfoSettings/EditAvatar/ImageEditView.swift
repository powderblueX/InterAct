//
//  ImageEditView.swift
//  EcoStep
//
//  Created by admin on 2024/11/24.
//

import SwiftUI

struct ImageEditView: View {
    @State private var editedImage: UIImage
    @Environment(\.dismiss) private var dismiss
    let onSave: (UIImage) -> Void

    init(image: UIImage, onSave: @escaping (UIImage) -> Void) {
        self._editedImage = State(initialValue: image)
        self.onSave = onSave
    }

    var body: some View {
        VStack {
            Image(uiImage: editedImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 400)
                .padding()

            HStack {
                Button("裁剪") {
                    if let cropped = cropImage(image: editedImage) {
                        editedImage = cropped
                    }
                }
                .padding()

                Button("保存") {
                    onSave(editedImage)
                    dismiss()
                }
                .padding()
            }
        }
    }

    private func cropImage(image: UIImage) -> UIImage? {
        let size = CGSize(width: image.size.width / 2, height: image.size.height / 2)
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContext(size)
        image.draw(in: rect)
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
}
