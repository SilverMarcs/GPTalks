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
    var dataFiles: [TypedData]
    @State private var selectedFileURL: URL?
    @State private var isQuickLookPresented = false
    
    let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(dataFiles.indices, id: \.self) { index in
                let typedData = dataFiles[index]
                Button {
                    if let url = FileHelper.createTemporaryURL(for: typedData) {
                        selectedFileURL = url
                        isQuickLookPresented = true
                    }
                } label: {
                    HStack {
                        Image(systemName: iconName(for: typedData.fileType))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.accent)
                        
                        
                        VStack(alignment: .leading) {
                            Text(typedData.fileName)
                                .font(.caption)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .bold()
                            
                            Text(String(typedData.fileSize))
                                .font(.caption)
                        }
                    }
                    
                    .padding(10)
                    .frame(width: 125, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                        #if os(macOS)
                            .fill(.background.quinary)
                        #else
                            .fill(.background.secondary)
                        #endif
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 5)
        .quickLookPreview($selectedFileURL)
    }
    
    func iconName(for fileType: UTType) -> String {
        if fileType.conforms(to: .pdf) {
            return "doc.fill"
        } else if fileType.conforms(to: .image) {
            return "photo.fill"
        } else if fileType.conforms(to: .audio) {
            return "music.note"
        } else if fileType.conforms(to: .text) || fileType.conforms(to: .plainText) {
            return "doc.text.fill"
        } else {
            return "doc.fill"
        }
    }
}
