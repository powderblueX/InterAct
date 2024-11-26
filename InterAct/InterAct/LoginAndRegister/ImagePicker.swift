////
////  ImagePicker.swift
////  EcoStep
////
////  Created by admin on 2024/11/23.
////
//
//import SwiftUI
//
//struct ImagePicker: View {
//    @Binding var image: UIImage?
//    
//    @State private var isImagePickerPresented = false
//    
//    var body: some View {
//        VStack {
//            Button("Select Image") {
//                isImagePickerPresented.toggle()
//            }
//            .imagePicker(isPresented: $isImagePickerPresented, image: $image)
//        }
//    }
//}
//
//extension View {
//    func imagePicker(isPresented: Binding<Bool>, image: Binding<UIImage?>) -> some View {
//        ImagePickerController(isPresented: isPresented, image: image)
//    }
//}
//
//struct ImagePickerController: UIViewControllerRepresentable {
//    @Binding var isPresented: Bool
//    @Binding var image: UIImage?
//    
//    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        @Binding var isPresented: Bool
//        @Binding var image: UIImage?
//        
//        init(isPresented: Binding<Bool>, image: Binding<UIImage?>) {
//            _isPresented = isPresented
//            _image = image
//        }
//        
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            isPresented = false
//        }
//        
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let selectedImage = info[.originalImage] as? UIImage {
//                image = selectedImage
//            }
//            isPresented = false
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(isPresented: $isPresented, image: $image)
//    }
//    
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//}
//
//
