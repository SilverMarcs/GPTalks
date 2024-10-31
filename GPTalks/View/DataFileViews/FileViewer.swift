//
//  PDFViewer.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/20/24.
//

import SwiftUI

struct FileViewer: View {
    let typedData: TypedData
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            GroupBox {
                HStack {
                    Image(platformImage: typedData.imageName)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                    
                    VStack(alignment: .leading) {
                        Text(typedData.fileName.truncateText())
                            .font(.callout)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        Text("\(typedData.fileExtension.uppercased()) • \(typedData.fileSize)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .groupBoxStyle(PlatformSpecificGroupBoxStyle())
        }
        .buttonStyle(.plain)
    }
}
