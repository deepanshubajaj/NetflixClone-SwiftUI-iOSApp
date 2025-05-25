//
//  SplashAudioViewModel.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 25/05/25.
//

import Foundation
import AVFoundation

import SwiftUI
import SDWebImageSwiftUI
import AVFoundation

// ViewModel to manage the audio player
class SplashAudioViewModel: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        setupAudio()
    }
    
    private func setupAudio() {
        guard let path = Bundle.main.path(forResource: "netflixAudio", ofType: "mp3") else {
            print("Audio file not found")
            return
        }
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error setting up audio player: \(error)")
        }
    }
    
    func play() {
        audioPlayer?.play()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
