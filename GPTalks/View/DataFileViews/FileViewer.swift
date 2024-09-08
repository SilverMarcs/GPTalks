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
            HStack {
                Image(platformImage: typedData.image)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
                
                VStack(alignment: .leading) {
                    Text(typedData.fileName)
                       .font(.callout)
                       .fontWeight(.bold)
                       .lineLimit(1)
                       .truncationMode(.middle)
                    
                    Text("\(typedData.fileExtension.uppercased()) • \(typedData.fileSize)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .padding(5)
        .background(RoundedRectangle(cornerRadius: 10).fill(.background.tertiary))
        .buttonStyle(.plain)
    }
}
