//
//  PDFViewer.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/20/24.
//

import SwiftUI

struct FileViewer: View {
    let typedData: TypedData
    
    var body: some View {
        GroupBox {
            HStack {
                Image(platformImage: typedData.imageName)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
                
                VStack(alignment: .leading) {
                    Text((typedData.fileName as NSString).deletingPathExtension)
                        .font(.callout)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text("\(typedData.fileType.fileExtension.uppercased())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .groupBoxStyle(PlatformSpecificGroupBoxStyle())
    }
}
