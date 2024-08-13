//
//  InputImageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/07/2024.
//

import SwiftUI

struct InputImageView: View {
    var session: Session
    var maxHeight: CGFloat = 100
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(session.inputManager.imagePaths, id: \.self) { imagePath in
                    ImageViewer(imagePath: imagePath, maxWidth: .infinity, maxHeight: maxHeight, isCrossable: true) {
                        if let index = session.inputManager.imagePaths.firstIndex(of: imagePath) {
                            session.inputManager.imagePaths.remove(at: index)
                            FileHelper.deleteFile(at: imagePath)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let config = SessionConfig()
    let session = Session(config: config)
    InputImageView(session: session)
}
