//
//  SplashScreenView.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 24/05/25.
//

import SwiftUI
import SDWebImageSwiftUI
import AVFoundation

struct SplashScreenView: View {
    
    @State private var isShowSplash: Bool = true
    @EnvironmentObject var appState: AppState
    @StateObject private var audioVM = SplashAudioViewModel()
    
    var body: some View {
        ZStack {
            if isShowSplash {
                AnimatedImage(url: URL(string: "https://c.tenor.com/y9wRo5oAad4AAAAC/tenor.gif"))
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
            } else if appState.showWhoWatching {
                WhoWatching(onProfileSelected: {
                    appState.showWhoWatching = false
                })
            } else {
                TabBar()
            }
        }
        .onAppear {
            audioVM.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    self.isShowSplash = false
                    appState.showWhoWatching = true
                    audioVM.stop()
                }
            }
        }
    }
}

#Preview {
    SplashScreenView().environmentObject(AppState())
}
