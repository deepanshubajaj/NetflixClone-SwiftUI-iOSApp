//
//  SampleView.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 23/05/25.
//

import SwiftUI
import SDWebImageSwiftUI
import UIKit

struct NotificationItem: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let subtitle: String
    let date: String
}

struct LikedShow: Identifiable {
    let id = UUID()
    let image: String
    let title: String
}

struct SampleView: View {
    @State private var likedTitles: [String] = []
    @State private var selectedMovie: MovieDetailModel? = nil
    @State private var myListMovies: [MovieDetailModel] = []
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject private var profileManager = ProfileManager()
    @State private var selectedProfile: Profile? = nil
    @EnvironmentObject var appState: AppState
    @State private var isNotificationSectionHighlighted: Bool = false
    @State private var youtubeVideos: [YouTubeVideo] = []
    @State private var isLoading: Bool = false
    @State private var showDownloads: Bool = false
    @State private var showAboutAlert = false
    @State private var showSearch = false
    
    private let youTubeService = YouTubeService()
    
    // Dummy Data
    let notifications = [
        NotificationItem(image: "hourglass", title: "Last call to watch", subtitle: "Time's (almost) up on these", date: "Today"),
        NotificationItem(image: "royals", title: "New arrival", subtitle: "The Royals", date: "13 May")
    ]
    
    // Dummy data for images (map titles to images)
    let allShows: [String: String] = [
        "Death Note": "deathnote",
        "Squid Game": "squidgame",
        "It's What's Inside": "inside",
        "Music": "music"
        // Add more as needed
    ]
    
    var allMovies: [MovieDetailModel] {
        let homeMovies = viewModel.homeSection.flatMap { section in
            switch section {
            case .trendingMovies(let movies): return movies
            case .trendingTv(let tv): return tv
            case .popular(let popular): return popular
            case .upComing(let upComing): return upComing
            case .topRate(let topRated): return topRated
            case .myList(let myList): return myList
            }
        }
        return Array(Set(homeMovies + myListMovies))
    }
    
    var likedMovies: [MovieDetailModel] {
        allMovies.filter { likedTitles.contains($0.title ?? "") }
    }
    
    // Helper to get the selected profile
    func getSelectedProfile() -> Profile? {
        if let idString = UserDefaults.standard.string(forKey: "selectedProfileId"),
           let id = UUID(uuidString: idString),
           let profile = profileManager.profiles.first(where: { $0.id == id }) {
            return profile
        }
        return profileManager.profiles.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        Text("My Netflix")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                        HStack(spacing: 20) {
                            Button(action: {
                                showDownloads.toggle()
                            }) {
                                Image(systemName: "arrow.down.to.line")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                            
                            AirPlayButtonView()
                                .frame(width: 30, height: 30)
                            
                            Button(action: {
                                showSearch = true
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                            .sheet(isPresented: $showSearch) {
                                NavigationStack {
                                    SearchContentView()
                                        .toolbar {
                                            ToolbarItem(placement: .navigationBarLeading) {
                                                Button(action: {
                                                    showSearch = false
                                                }) {
                                                    Image(systemName: "chevron.down")
                                                        .foregroundColor(.white)
                                                        .imageScale(.large)
                                                }
                                            }
                                        }
                                }
                            }
                            
                            // Updated line.3.horizontal button
                            Button(action: {
                                showAboutAlert = true
                            }) {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 28) {
                            // Profile Section
                            let profile = getSelectedProfile()
                            VStack(spacing: 8) {
                                Image(profile?.imageName ?? "DP")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                    .shadow(radius: 4)
                                    .padding(.top, 8)
                                Button(action: {
                                    appState.showWhoWatching = true
                                }) {
                                    HStack(spacing: 4) {
                                        Text(profile?.name ?? "DEEPANSHU")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .textCase(.uppercase)
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.white)
                                            .font(.subheadline)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Notifications Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "bell.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                    Text("Notifications")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .opacity(isNotificationSectionHighlighted ? 1 : 0)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // Create highlight effect
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isNotificationSectionHighlighted = true
                                    }
                                    
                                    // Existing notification code
                                    NotificationManager.shared.requestAuthorization()
                                    NotificationManager.shared.sendNotification(title: "Last call to watch", body: "Time's (almost) up on these", imageName: "hourglassN", imageExtension: "jpg")
                                    NotificationManager.shared.sendNotification(title: "New Arrival", body: "The Royals", imageName: "royalsN", imageExtension: "jpg")
                                    
                                    // Reset highlight after a delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            isNotificationSectionHighlighted = false
                                        }
                                    }
                                }
                                
                                ForEach(notifications) { notification in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(notification.image)
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(notification.title)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text(notification.subtitle)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            Text(notification.date)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Downloads Section
                            Button(action: {
                                showDownloads = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                    Text("Downloads")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                            // Liked Shows Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("TV Shows & Movies You have Liked")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(likedMovies, id: \.id) { movie in
                                            Button {
                                                selectedMovie = movie
                                            } label: {
                                                if let poster = movie.poster_path {
                                                    WebImage(url: URL(string: Constant.imageURL + poster))
                                                        .resizable()
                                                        .frame(width: 120, height: 170)
                                                        .cornerRadius(8)
                                                } else {
                                                    ZStack {
                                                        Rectangle()
                                                            .fill(Color.gray.opacity(0.3))
                                                            .frame(width: 120, height: 170)
                                                            .cornerRadius(8)
                                                        Text(movie.title ?? "")
                                                            .foregroundColor(.white)
                                                            .multilineTextAlignment(.center)
                                                            .padding()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            // My List Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("My List")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(myListMovies, id: \.id) { movie in
                                            Button {
                                                selectedMovie = movie
                                            } label: {
                                                if let poster = movie.poster_path {
                                                    WebImage(url: URL(string: Constant.imageURL + poster))
                                                        .resizable()
                                                        .frame(width: 120, height: 170)
                                                        .cornerRadius(8)
                                                } else {
                                                    ZStack {
                                                        Rectangle()
                                                            .fill(Color.gray.opacity(0.3))
                                                            .frame(width: 120, height: 170)
                                                            .cornerRadius(8)
                                                        Text(movie.title ?? "")
                                                            .foregroundColor(.white)
                                                            .multilineTextAlignment(.center)
                                                            .padding()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        likedTitles = LikedMoviesManager.shared.getLikedMovies()
                        myListMovies = UserList.shared.movies
                        do {
                            try await viewModel.manageHomeResponse()
                        } catch {
                            print("Failed to refresh home sections: \(error)")
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedMovie) { movie in
                ZStack(alignment: .topTrailing) {
                    MovieDetailView(movie: movie, viewModel: viewModel)
                    Button(action: {
                        selectedMovie = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }
            .sheet(isPresented: $showDownloads) {
                DownloadsView(isPresented: $showDownloads)
                    .ignoresSafeArea()
            }
            
            // Add alert here
            .alert("About", isPresented: $showAboutAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("NetflixClone App is Designed & Developed by: Deepanshu Bajaj")
            }
            
        }
        .onAppear {
            likedTitles = LikedMoviesManager.shared.getLikedMovies()
            myListMovies = UserList.shared.movies
        }
    }
}

#Preview {
    SampleView()
        .environmentObject(AppState())
}
