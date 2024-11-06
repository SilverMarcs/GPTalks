//
//  CameraView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/09/2024.
//

#if !os(macOS)
import SwiftUI
import UniformTypeIdentifiers

struct CameraView: UIViewControllerRepresentable {
    var chat: Chat
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        #if !os(visionOS)
        imagePicker.sourceType = .camera
        #endif
        imagePicker.allowsEditing = false
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self, chat: chat)
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: CameraView
    var chat: Chat
    
    init(picker: CameraView, chat: Chat) {
        self.picker = picker
        self.chat = chat
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage,
              let imageData = selectedImage.jpegData(compressionQuality: 0.7) else { return }
        
        let fileType = UTType.image
        let fileName = "Camera_\(UUID().uuidString)"
        
        let typedData = TypedData(
            data: imageData,
            fileType: fileType,
            fileName: fileName
        )
        
        chat.inputManager.dataFiles.append(typedData)
        chat.showCamera = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        chat.showCamera = false
    }
}
#endif
