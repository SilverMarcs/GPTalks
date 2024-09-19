//
//  DataFileView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/08/2024.
//

import SwiftUI
import QuickLook
import UniformTypeIdentifiers

struct DataFileView: View {
    @Binding var dataFiles: [TypedData]
    var isCrossable: Bool
    var edge: HorizontalAlignment = .leading
    
    @State private var selectedFileURL: URL?
    
    var body: some View {
        VStack(alignment: edge, spacing: 10) {
            // Image files
            if !imageFiles.isEmpty {
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(imageFiles, id: \.self) { typedData in
                        fileItemView(for: typedData)
                    }
                }
            }
            
            // Other data files
            if !otherFiles.isEmpty {
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(otherFiles, id: \.self) { typedData in
                        fileItemView(for: typedData)
                    }
                }
            }
        }
        .quickLookPreview($selectedFileURL)
    }
    
    private var imageFiles: [TypedData] {
        dataFiles.filter { $0.fileType.conforms(to: .image) }
    }
    
    private var otherFiles: [TypedData] {
        dataFiles.filter { !$0.fileType.conforms(to: .image) }
    }
    
    @ViewBuilder
    private func fileItemView(for typedData: TypedData) -> some View {
        ZStack(alignment: .topLeading) {
            fileView(for: typedData)
            
            if isCrossable {
                Button {
                    dataFiles.removeAll(where: { $0.id == typedData.id })
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white)
                        #if !os(macOS)
                        .padding(10) // Increase padding for better touch area
                        #endif
                        .contentShape(.rect)
                }
                .shadow(radius: 5)
                .buttonStyle(.plain)
            }
        }
    }
    
    @ViewBuilder
    func fileView(for typedData: TypedData) -> some View {
        if typedData.fileType.conforms(to: .image) {
            ImageViewer(typedData: typedData, onTap: { presentQuickLook(for: typedData) })
        } else {
            FileViewer(typedData: typedData, onTap: { presentQuickLook(for: typedData) })
        }
    }
    
    func presentQuickLook(for typedData: TypedData) {
        if let url = FileHelper.createTemporaryURL(for: typedData) {
            selectedFileURL = url
        }
    }
}
