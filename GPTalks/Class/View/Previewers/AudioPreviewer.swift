//
//  AudioPreviewer.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/04/2024.
//

import SwiftUI
import QuickLook

struct AudioPreviewer: View {
    var audioURL: URL
    var showRemoveButton: Bool = true
    var removeAudioAction: () -> Void
    
    @State var qlItem: URL?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if !AppConfiguration.shared.alternateAudioPlayer {
                AudioPlayerView(audioURL: audioURL)
                    .frame(maxWidth: 500)
            } else {
                Button {
                    qlItem = audioURL
                } label: {
                    HStack {
                        Group {
                            #if os(macOS)
                            Image(nsImage: getFileTypeIcon(fileURL: audioURL)!)
                                .resizable()
                            #else
                            Image("audio")
                                .resizable()
                            #endif
                        }
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading) {
                            Text(audioURL.lastPathComponent)
                                .font(.callout)
                                .fontWeight(.bold)
                            
                            if let fileSize = getFileSizeFormatted(fileURL: audioURL) {
                                HStack(spacing: 2) {
                                    Group {
                                        Text("Audio •")
                                            .font(.caption)
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
            }

            if showRemoveButton {
                CustomCrossButton(action: removeAudioAction)
                    .padding(-10)
            }
        }
        .quickLookPreview($qlItem)
    }
}
