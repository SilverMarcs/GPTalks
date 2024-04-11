//
//  AudioPlayerView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/03/2024.
//

import AVFoundation
import SwiftUI

struct AudioPlayerView: View {
    var audioURL: URL
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var audioProgress: Double = 0.0
    @State private var audioVolume: Float = 1.0
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Button {
                    self.togglePlayPause()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
                
                Text("\(formatTime(time: currentTime))")
                
//                ProgressWaveformView(audioURL: audioURL, progress: $audioProgress) {
//                    self.sliderEditingChanged(editingStarted: false) // Call when dragging ends
//                }
//                .frame(height: 30)
                Slider(value: $audioProgress, in: 0...1, onEditingChanged: sliderEditingChanged)
                    .controlSize(.small)
                
                Text("\(formatTime(time: duration))")
            }
            .bubbleStyle(isMyMessage: false)
        }
        .onAppear {
            self.preparePlayer()
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                guard let player = audioPlayer, player.isPlaying else { return }
                audioProgress = player.currentTime / player.duration
                currentTime = player.currentTime
                if audioProgress >= 1.0 {
                    timer.invalidate()
                }
            }

        }
    }
    
    func preparePlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0
        } catch {
            print("Error initializing player: \(error)")
        }
    }
    
    func togglePlayPause() {
        guard let player = audioPlayer else { return }
        
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            audioPlayer?.pause()
        } else {
            if let duration = audioPlayer?.duration {
                audioPlayer?.currentTime = TimeInterval(audioProgress) * duration
                if isPlaying {
                    audioPlayer?.play()
                }
            }
            currentTime = audioPlayer?.currentTime ?? 0
        }
    }
    
    func formatTime(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}

import DSWaveformImage
import DSWaveformImageViews
import SwiftUI

struct ProgressWaveformView: View {
    let audioURL: URL
    @Binding var progress: Double // Make progress a Binding variable
    var onDragEnd: () -> Void
    @State var width = CGFloat(4) // Width of the slider handle
    
    @State private var isHovering = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                WaveformView(audioURL: audioURL) { shape in
                    shape.fill(.foreground)
                    shape.fill(Color.accentColor).mask(alignment: .leading) {
                        Rectangle().frame(width: geometry.size.width * progress)
                    }
                }
                // Custom Slider Handle
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue)
//                    .frame(width: width, height: geometry.size.height)
                    .frame(width: isHovering ? 12 : 4, height: geometry.size.height)
                    .offset(x: geometry.size.width * progress - 1)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newProgress = value.location.x / geometry.size.width
                                progress = min(max(0, newProgress), 1)
                            }
                            .onEnded { _ in
                                onDragEnd()
                            }
                    )
                    .animation(.easeInOut, value: progress)
                    .background(
                        Color.red
                            .frame(width: 20, height: geometry.size.height) // Adjust the width to control the hover area
                            .contentShape(Rectangle())
                            .offset(x: geometry.size.width * progress - 1)
                            .onHover { hovering in
                                withAnimation {
                                    isHovering = hovering
                                    width = hovering ? 12 : 4
                                }
                            }
                    )
            }
        }
    }
}
