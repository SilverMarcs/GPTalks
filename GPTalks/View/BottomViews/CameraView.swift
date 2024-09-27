//
//  CameraView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/09/2024.
//

#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

struct CameraView: UIViewControllerRepresentable {
    
    var onDataAppend: (TypedData) -> Void
    @Environment(\.presentationMode) var isPresented
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false // Ensure full-sized image
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self, onDataAppend: onDataAppend)
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: CameraView
    var onDataAppend: (TypedData) -> Void
    
    init(picker: CameraView, onDataAppend: @escaping (TypedData) -> Void) {
        self.picker = picker
        self.onDataAppend = onDataAppend
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage,
              let imageData = selectedImage.jpegData(compressionQuality: 1.0) else { return }
        
        let fileType = UTType.image
        let fileName = UUID().uuidString
        let fileSize = ByteCountFormatter.string(fromByteCount: Int64(imageData.count), countStyle: .file)
        let fileExtension = "jpeg"
        
        let typedData = TypedData(
            data: imageData,
            fileType: fileType,
            fileName: fileName,
            fileSize: fileSize,
            fileExtension: fileExtension
        )
        
        self.onDataAppend(typedData)
        self.picker.isPresented.wrappedValue.dismiss()
    }
}
#endif
