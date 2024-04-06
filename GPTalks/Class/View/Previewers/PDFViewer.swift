//
//  PDFViewer.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/04/2024.
//

import SwiftUI

struct PDFViewer: View {
    var pdfURL: URL
    var removePDFAction: () -> Void
    var showRemoveButton: Bool = true
    
    @State var qlItem: URL?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                qlItem = pdfURL
            } label: {
                HStack {
                    Image("pdftype")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading) {
                        Text(pdfURL.lastPathComponent)
                           .font(.callout)
                           .fontWeight(.bold)
                        
                        if let fileSize = getFileSizeFormatted(fileURL: pdfURL) {
                            HStack(spacing: 2) {
                                Group {
                                    Text("PDF •")
                                        .font(.caption)
//                                        .fontWeight(.semibold)
                                    Text(fileSize)
                                        .font(.caption)
                                }
                                .foregroundStyle(.secondary)
                            }
                        } else {
                            
                            Text("Unknown size")
                                .font(.caption)
                        }
                    }
                    
                }
                .bubbleStyle(isMyMessage: false, radius: 10)
            }
            .buttonStyle(.plain)

            // TODO: show this based on a a prameter
            if showRemoveButton {
                CustomCrossButton(action: removePDFAction)
                    .padding(-10)
            }
        }
        .quickLookPreview($qlItem)
    }
}
