//
//  ImageZoomableView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/02/2024.
//

import SwiftUI

struct ZoomableImageView: View {
    let imageUrl: URL?
    @State private var zoomScale: CGFloat = 1.0

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(zoomScale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    zoomScale = value
                                    if zoomScale < 1.0 {
                                        zoomScale = 1.0
                                    }
                                }
                        )
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close") {
                                    dismiss()
                                }
                            }
                        }
                        .onTapGesture(count: 2) {
                            withAnimation {
                                zoomScale = 1.0
                            }
                        }
                } placeholder: {
                    ProgressView()
                }
            }
            .background(.black)
        }
    }
}

//#Preview {
//    ImageZoomableView()
//}
