//
//  HomeViewModel.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 22/05/25.
//

import Foundation
import Combine

enum TopButtonType : Hashable, Identifiable {
    case play, add
    var id: TopButtonType { self }
}

final class HomeViewModel : ObservableObject {
    
    @Published var imageAnimation: Bool = false
    @Published var homeSection: [HomeSection] = []
    @Published var activeTag: String = "trending Movies"
    @Published var isloading: Bool = false
    @Published var bannerMovies: [MovieDetailModel] = []
    @Published var userList: UserList = UserList.shared
    @Published var newsAndHotMovies: [MovieDetailModel] = []
    
    private var serviceManger: HomeManagerDelegate
    
    init(serviceManger: HomeManagerDelegate = HomeManager()) {
        self.serviceManger = serviceManger
        // Load saved movies
        self.userList = UserList.shared
        Task {
            try await manageHomeResponse()
            try await fetchNewsAndHotMovies()
        }
    }
    
    func toggleMovieInList(_ movie: MovieDetailModel) {
        print("Toggling movie in list: \(movie.title ?? "Unknown")")
        if userList.contains(movie) {
            print("Removing movie from list")
            userList.removeMovie(movie)
        } else {
            print("Adding movie to list")
            userList.addMovie(movie)
        }
        print("Current list count: \(userList.movies.count)")
        UserList.shared = userList
        
        // Update the homeSection to reflect changes in My List
        updateMyListSection()
    }
    
    private func updateMyListSection() {
        // Remove existing My List section if it exists
        homeSection.removeAll { section in
            if case .myList = section { 
                print("Removing existing My List section")
                return true 
            }
            return false
        }
        
        // Add My List section if there are any movies
        if !userList.movies.isEmpty {
            print("Adding My List section with \(userList.movies.count) movies")
            homeSection.append(.myList(model: userList.movies))
        } else {
            print("No movies in list, not adding My List section")
        }
    }
    
    func isMovieInList(_ movie: MovieDetailModel) -> Bool {
        userList.contains(movie)
    }
}
// MARK: - Funcationality and Business Logic
extension HomeViewModel {
    var bannerImage : URL? {
        return URL(string: Constant.imageURL+(bannerMovies.first?.poster_path ?? ""))
    }
    
    func fetchYoutubeVideo(for movie: MovieDetailModel) async throws -> Item? {
        guard let title = movie.title else { 
            print("No movie title available")
            return nil 
        }
        let searchQuery = "\(title) official trailer"
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let youtubeUrl = "\(Constant.youtube_BaseUrl)q=\(encodedQuery)&key=\(Constant.youtube_Api_key)&type=video&videoEmbeddable=true&videoSyndicated=true"
        
        print("YouTube API URL: \(youtubeUrl)")
        
        guard let url = URL(string: youtubeUrl) else { 
            print("Invalid YouTube URL")
            return nil 
        }
        
        let (_, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response type")
            return nil
        }
        
        print("YouTube API Response Status: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode == 200 {
            let item = try await serviceManger.fetchYoutubeUrl(url: url)
            print("YouTube API response: \(item?.id.videoID ?? "No video ID")")
            return item
        } else {
            print("YouTube API Error: Status code \(httpResponse.statusCode)")
            return nil
        }
    }
}

// MARK: - API Response Handler
extension HomeViewModel {
    
    @MainActor
    func manageHomeResponse() async throws {
        isloading = true
        let popularResult = try await fetchPopular()
        let trendingMovieResult = try await fetchTrendingMovies()
        let trendingTvResult = try await fetchTrendingTv()
        let upComingResult = try await fetchUpComing()
        let topRatedResult = try await fetchTopRated()
        
        // Get 5 random movies for the banner
        bannerMovies = Array(popularResult.shuffled().prefix(5))
        
        homeSection.removeAll()
        homeSection.append(.trendingMovies(model: trendingMovieResult))
        homeSection.append(.popular(model: popularResult))
        homeSection.append(.trendingTv(model: trendingTvResult))
        homeSection.append(.upComing(model: upComingResult))
        homeSection.append(.topRate(model: topRatedResult))
        
        // Add My List section if there are any movies
        if !userList.movies.isEmpty {
            homeSection.append(.myList(model: userList.movies))
        }
        
        isloading = false
    }
    
    @MainActor
    private func fetchPopular()  async throws -> [MovieDetailModel] {
        guard let popularUrl = URL(string: Constant.discoverUrl) else {return []}
        let popularResult = try await serviceManger.getPopularMovies(url: popularUrl)
        return popularResult
    }
    
    @MainActor
    private func fetchTrendingMovies()  async throws -> [MovieDetailModel]{
        guard let trendingUrl = URL(string: Constant.trandingMovie) else {return []}
        let trendingResult = try await serviceManger.getTrendingMovies(url: trendingUrl)
        return trendingResult
    }
    
    @MainActor
    private func fetchTrendingTv()  async throws -> [MovieDetailModel]{
        guard let trendingUrl = URL(string: Constant.trendingTv) else {return []}
        let trendingResult = try await serviceManger.getTrendingTV(url: trendingUrl)
        return trendingResult
    }
    
    @MainActor
    private func fetchUpComing()  async throws -> [MovieDetailModel]{
        guard let trendingUrl = URL(string: Constant.getUpComing) else {return []}
        let trendingResult = try await serviceManger.getUpComing(url: trendingUrl)
        return trendingResult
    }
    
    @MainActor
    private func fetchTopRated()  async throws -> [MovieDetailModel]{
        guard let trendingUrl = URL(string: Constant.getTopRated) else {return []}
        let trendingResult = try await serviceManger.getTopRated(url: trendingUrl)
        return trendingResult
    }
    
    @MainActor
    func fetchMovieCredits(movieId: Int) async throws -> [Cast] {
        guard let url = URL(string: "\(Constant.baseURl)/movie/\(movieId)/credits?api_key=\(Constant.Api_Key)") else {
            return []
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(CreditsResponse.self, from: data)
        return response.cast
    }
    
    @MainActor
    func fetchMovieDetails(movieId: Int) async throws -> MovieDetailModel {
        guard let url = URL(string: "\(Constant.baseURl)/movie/\(movieId)?api_key=\(Constant.Api_Key)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(MovieDetailModel.self, from: data)
    }
    
    @MainActor
    func fetchNewsAndHotMovies() async throws {
        guard let url = URL(string: "\(Constant.baseURl)/movie/now_playing?api_key=\(Constant.Api_Key)") else { return }
        let result = try await serviceManger.getPopularMovies(url: url)
        newsAndHotMovies = result
    }
}
