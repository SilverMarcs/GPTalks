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
                #if os(macOS)
                Button {
                    dataFiles.removeAll(where: { $0.id == typedData.id })
                } label: {
                    Label("Remove", systemImage: "xmark.circle.fill")
                        
                }
                .buttonStyle(HoverScaleButtonStyle())
                .shadow(radius: 5)
                .padding(.bottom, 5)
                .padding(.trailing, 5)
                #else
                Button {
                    dataFiles.removeAll(where: { $0.id == typedData.id })
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.background, .primary)
                        .padding(10) // Increase padding for better touch area
                        .contentShape(.rect)
                }
                .shadow(radius: 5)
                .buttonStyle(.plain)
                .padding(3)
                #endif
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
