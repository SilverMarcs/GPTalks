//
//  InputImageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/07/2024.
//

import SwiftUI

struct InputImageView: View {
    var session: Session
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(session.inputManager.imagePaths, id: \.self) { imagePath in
                    ImageViewer(imagePath: imagePath, maxWidth: .infinity) {
                        if let index = session.inputManager.imagePaths.firstIndex(of: imagePath) {
                            session.inputManager.imagePaths.remove(at: index)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    InputImageView(session: Session())
}
