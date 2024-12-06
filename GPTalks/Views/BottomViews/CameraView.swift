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
    var chatVM: ChatVM
    
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
        return Coordinator(picker: self, chatVM: chatVM)
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: CameraView
    var chatVM: ChatVM
    
    init(picker: CameraView, chatVM: ChatVM) {
        self.picker = picker
        self.chatVM = chatVM
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage,
              let imageData = selectedImage.jpegData(compressionQuality: 0.7) else { return }
        
        Task {
            let chat: Chat
            if let activeChat = chatVM.activeChat {
                chat = activeChat
            } else {
                chat = await chatVM.createNewChat()
            }
            
            try? await chat.inputManager.processData(
                imageData,
                fileType: .image,
                fileName: "Camera_\(UUID().uuidString)"
            )
            
            await MainActor.run {
                AppConfig.shared.showCamera = false
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        AppConfig.shared.showCamera = false
    }
}
#endif
