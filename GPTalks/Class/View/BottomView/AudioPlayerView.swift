//
//  AudioPlayerView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/03/2024.
//

import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    var audioURL: URL
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var audioProgress: Float = 0.0
    @State private var audioVolume: Float = 1.0
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Button {
                    self.togglePlayPause()
                }label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                
                Text("\(formatTime(time: currentTime))")
                
                Slider(value: $audioProgress, in: 0...1, onEditingChanged: sliderEditingChanged)
                    .controlSize(.small)
                
                Text("\(formatTime(time: duration))")
                
            }
            .bubbleStyle(isMyMessage: false)
            
//            Slider(value: $audioVolume, in: 0...1) { _ in
//                audioPlayer?.volume = audioVolume
//            }
        }
        .onAppear {
            self.preparePlayer()
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                guard let player = audioPlayer, player.isPlaying else { return }
                audioProgress = Float(player.currentTime / player.duration)
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
