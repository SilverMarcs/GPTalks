//
//  GenerationView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI

struct GenerationView: View {
    @ObservedObject var imageConfig = ImageConfigDefaults.shared
    var generation: Generation
    private let spacing: CGFloat = 10
    private let size: CGFloat = 300
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()

                if generation.state == .generating {
                    ActionButton(isStop: true) {
                        generation.stopGenerating()
                    }
                }
                
                Text(generation.config.prompt)
                    .textSelection(.enabled)
                    .padding(.vertical, 7)
                    .padding(.horizontal, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                        #if os(macOS)
                            .fill(.background.quinary)
                        #else
                            .fill(.background.secondary)
                        #endif
                    )
            }
            
            
            VStack(alignment: .leading) {
                Text(generation.config.model.name)
                    .font(.caption)
                    .padding(.leading, 5)
                    .foregroundStyle(LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                
                if generation.state == .error {
                    Text(generation.errorMessage)
                        .textSelection(.enabled)
                        .foregroundStyle(.red)
                        .padding(.leading, 5)
                        .padding(.top, 1)
                } else {
                    LazyVGrid(columns: gridColumns, alignment: .leading, spacing: spacing) {
                        if generation.state == .generating {
                            ForEach(1 ... generation.config.numImages, id: \.self) { image in
                                ProgressView()
                                    .frame(width: size, height: size)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.background.quinary)
                                    )
                            }
                        } else if generation.state == .success {
                            ForEach(generation.images, id: \.self) { image in
                                ImageViewerData(data: image)
                            }
                        }
                    }
                }
            }
        }
        .contentShape(.rect)
        .contextMenu {
            Button {
                generation.config.prompt.copyToPasteboard()
            } label: {
                Label("Copy Prompt", systemImage: "document.on.clipboard")
            }
            
            Button(role: .destructive) {
                generation.deleteSelf()
            } label: {
                Label("Delete Generation", systemImage: "trash")
            }
        }
    }
    
    private var gridColumns: [GridItem] {
        #if os(iOS)
        [GridItem(.fixed(size), spacing: spacing)]
        #else
        [GridItem(.fixed(size), spacing: spacing),
        GridItem(.fixed(size), spacing: spacing)]
        #endif
    }
}


#Preview {
    GenerationView(generation: .mockGeneration)
}
