//
//  MovieDetailView.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 23/05/25.
//

import SwiftUI
import SDWebImageSwiftUI
import WebKit

struct MovieDetailView: View {
    let movie: MovieDetailModel
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: HomeViewModel
    @StateObject private var webViewState = WebViewState()
    
    @State private var showVideo = false
    @State private var youtubeItem: Item?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var cast: [Cast] = []
    @State private var movieDetails: MovieDetailModel?
    @State private var isLoadingDetails = true
    @State private var isLiked = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                WebImage(url: URL(string: Constant.imageURL + (movie.poster_path ?? "")))
                    .placeholder(Image("placeholder"))
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                // Action Buttons
                HStack(spacing: 20) {
                    Button {
                        Task {
                            await fetchYoutubeVideo()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Play")
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .accessibilityLabel("Play trailer for \(movie.title ?? "movie")")
                    }
                    .padding(.horizontal)
                    .disabled(isLoading)
                    
                    Button {
                        viewModel.toggleMovieInList(movie)
                    } label: {
                        HStack {
                            Image(systemName: viewModel.isMovieInList(movie) ? "checkmark" : "plus")
                            Text(viewModel.isMovieInList(movie) ? "Added" : "My List")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    .padding(.horizontal)
                }
                
                if isLoading {
                    ProgressView("Loading trailer...")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.horizontal)
                }
                
                Text(movie.title ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Like button
                HStack {
                    Spacer()
                    Button(action: {
                        if isLiked {
                            LikedMoviesManager.shared.unlike(movieTitle: movie.title ?? "")
                        } else {
                            LikedMoviesManager.shared.like(movieTitle: movie.title ?? "")
                        }
                        isLiked.toggle()
                    }) {
                        Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .foregroundColor(isLiked ? .green : .white)
                            .font(.title2)
                            .padding(8)
                    }
                    Spacer()
                }
                .padding(.bottom, 4)
                .onAppear {
                    isLiked = LikedMoviesManager.shared.isLiked(movieTitle: movie.title ?? "")
                }
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", movie.vote_average ?? 0.0))
                        .font(.headline)
                    Text("(\(Int(movie.popularity ?? 0)) views)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                if let releaseDate = movie.release_date {
                    Text("Release Date: \(releaseDate)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                
                Text("Overview")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text(movie.overview ?? "")
                    .font(.body)
                    .padding(.horizontal)
                
                if isLoadingDetails {
                    ProgressView("Loading details...")
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    if !cast.isEmpty {
                        Text("Cast")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(cast, id: \.id) { actor in
                                    VStack {
                                        WebImage(url: URL(string: Constant.imageURL + (actor.profile_path ?? "")))
                                            .placeholder(Image("placeholder"))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 150)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        
                                        Text(actor.name ?? "")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .lineLimit(1)
                                        
                                        Text(actor.character ?? "")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 100)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    if let movieDetails = movieDetails {
                        Text("Maturity Rating")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        if let adult = movieDetails.adult {
                            Text(adult ? "A" : "PG")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .padding(.horizontal)
                        }
                        
                        Text("This movie is")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        if let genres = movieDetails.genres {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(genres, id: \.id) { genre in
                                        Text(genre.name ?? "")
                                            .font(.subheadline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.gray.opacity(0.2))
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Text("Original Language")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        if let originalLanguage = movieDetails.original_language {
                            Text(originalLanguage.uppercased())
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .padding(4)
                        .scaleEffect(0.6)
                }
            }
        }
        .fullScreenCover(isPresented: $showVideo) {
            if let videoID = youtubeItem?.id.videoID {
                ZStack(alignment: .topTrailing) {
                    WebViewContainer(videoID: videoID, webViewState: webViewState)
                    
                    Button {
                        showVideo = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                            .padding(20)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)
            } else {
                Text("Video unavailable")
                    .foregroundColor(.white)
                    .background(Color.black)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .task {
            isLoadingDetails = true
            if let movieId = movie.id {
                do {
                    async let castTask = viewModel.fetchMovieCredits(movieId: movieId)
                    async let detailsTask = viewModel.fetchMovieDetails(movieId: movieId)
                    
                    let (castResult, detailsResult) = try await (castTask, detailsTask)
                    cast = castResult
                    movieDetails = detailsResult
                } catch {
                    print("Error fetching movie details: \(error)")
                }
            }
            isLoadingDetails = false
        }
    }
    
    private func fetchYoutubeVideo() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let item = try await viewModel.fetchYoutubeVideo(for: movie)
            youtubeItem = item
            
            if (item?.id.videoID) != nil {
                showVideo = true
            } else {
                errorMessage = "No trailer found."
            }
        } catch {
            errorMessage = "Failed to fetch trailer."
        }
        
        isLoading = false
    }
}
