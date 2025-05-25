//
//  DownloadsView.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 25/05/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct DownloadsView: View {
    @Binding var isPresented: Bool
    @State private var youtubeVideos: [YouTubeVideo] = []
    @State private var isLoading: Bool = false
    
    private let youTubeService = YouTubeService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with Close Button
                    HStack {
                        Text("Downloads")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .padding(.trailing)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // YouTube Videos List
                    ScrollView {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding()
                        } else if youtubeVideos.isEmpty {
                            Text("No videos found")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 20) {
                                ForEach(youtubeVideos) { video in
                                    YouTubeVideoCell(video: video)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                fetchYouTubeVideos()
            }
        }
    }
    
    private func fetchYouTubeVideos() {
        isLoading = true
        youTubeService.fetchVideos(query: "netflix trailers") { videos in
            DispatchQueue.main.async {
                youtubeVideos = videos
                isLoading = false
            }
        }
    }
}

struct YouTubeVideoCell: View {
    let video: YouTubeVideo
    @State private var showPlayer = false
    
    var body: some View {
        VStack(alignment: .leading) {
            WebImage(url: URL(string: video.thumbnail))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 160, height: 90)
                .clipped()
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(.white)
                
                Text(video.channelTitle)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                showPlayer = true
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                    Text("Play")
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .sheet(isPresented: $showPlayer) {
                NavigationView {
                    WebView(url: URL(string: "https://www.youtube.com/watch?v=\(video.id)")!)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    showPlayer = false
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    // For preview purposes, create a constant binding
    DownloadsView(isPresented: .constant(true))
}
