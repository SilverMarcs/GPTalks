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
    let dataFiles: [TypedData]
    var edge: UnitPoint = .trailing
    var onDelete: ((TypedData) -> Void)? = nil
    
    @State private var selectedFileURL: URL?
    
    var body: some View {
        VStack {  // Keep the ScrollView but make it vertical
            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(Array(stride(from: 0, to: dataFiles.count, by: 3)), id: \.self) { index in
                    GridRow {
                        // Create a row with up to 3 items
                        ForEach(0..<min(3, dataFiles.count - index), id: \.self) { offset in
                            fileItemView(for: dataFiles[index + offset])
                        }
                    }
                }
            }
            .quickLookPreview($selectedFileURL)
        }
    }
    
    @ViewBuilder
    private func fileItemView(for typedData: TypedData) -> some View {
        ZStack(alignment: .topLeading) {
            fileView(for: typedData)
            
            if let onDelete {
                Button {
                    onDelete(typedData)
                } label: {
                    Label("Remove", systemImage: "xmark.circle.fill")
                        #if !os(macOS)
                        .padding(10)
                        .contentShape(.rect)
                        #endif
                }
                .padding(2)
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)
                .shadow(radius: 5)
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
