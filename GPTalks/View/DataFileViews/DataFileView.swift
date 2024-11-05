//
//  DataFileView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/08/2024.
//

import SwiftUI
import QuickLook
import UniformTypeIdentifiers

struct DataFilesView: View {
    @Binding var dataFiles: [TypedData]
    var isCrossable: Bool
    var edge: UnitPoint = .trailing
    
    @State private var selectedFileURL: URL?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(dataFiles) { dataFile in
                    fileItemView(for: dataFile)
                }
            }
            .quickLookPreview($selectedFileURL)
        }
        .defaultScrollAnchor(edge)
    }
    
    @ViewBuilder
    private func fileItemView(for typedData: TypedData) -> some View {
        ZStack(alignment: .bottomTrailing) {
            fileView(for: typedData)
            
            if isCrossable {
                Button {
                    withAnimation {
                        dataFiles.removeAll(where: { $0.id == typedData.id })
                    }
                } label: {
                    Label("Remove", systemImage: "xmark.circle.fill")
                        #if !os(macOS)
                        .padding(10) // Increase padding for better touch area
                        .contentShape(.rect)
                        #endif
                }
                .buttonStyle(HoverScaleButtonStyle())
                .shadow(radius: 5)
                .padding(.bottom, 5)
                .padding(.trailing, 5)
            }
        }
    }
    
    func fileView(for typedData: TypedData) -> some View {
        Button {
            if let url = FileHelper.createTemporaryURL(for: typedData) {
                selectedFileURL = url
            }
        } label: {
            if typedData.fileType.conforms(to: .image) {
                ImageViewer(typedData: typedData)
            } else {
                FileViewer(typedData: typedData)
            }
        }
        .buttonStyle(.plain)
    }
}
