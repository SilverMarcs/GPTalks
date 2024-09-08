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
    
    @State private var selectedFileURL: URL?
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(dataFiles, id: \.self) { typedData in
                ZStack(alignment: .topLeading) {
                    fileView(for: typedData)
                    
                    if isCrossable {
                        Button {
                            dataFiles.removeAll(where: { $0.id == typedData.id })
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white)
                        }
                        .shadow(radius: 5)
                        .buttonStyle(.plain)
                        .padding(5)
                    }
                }
            }
        }
        .quickLookPreview($selectedFileURL)
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

