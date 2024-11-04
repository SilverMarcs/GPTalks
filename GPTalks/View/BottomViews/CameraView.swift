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
    var session: ChatSession
    
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
        return Coordinator(picker: self, session: session)
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: CameraView
    var session: ChatSession
    
    init(picker: CameraView, session: ChatSession) {
        self.picker = picker
        self.session = session
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
        
        self.session.inputManager.dataFiles.append(typedData)
        self.session.showCamera = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.session.showCamera = false
    }
}
#endif
