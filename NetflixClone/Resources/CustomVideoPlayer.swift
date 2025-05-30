//
//  CustomVideoPlayer.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 23/05/25.
//

import SwiftUI
import AVKit

// Custom Video Player
struct CustomVideoPlayer: UIViewControllerRepresentable {
    
    var player : AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}

