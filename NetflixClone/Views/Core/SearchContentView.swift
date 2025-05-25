//
//  SearchContentView.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 23/05/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct SearchContentView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    @State private var selectedMovie: MovieDetailModel?
    
    var body: some View {
        VStack {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $searchText)
                    .foregroundColor(.white)
                    .onChange(of: searchText) { newValue in
                        Task {
                            await viewModel.searchMovies(query: newValue)
                        }
                    }
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Content
            ScrollView {
                if searchText.isEmpty {
                    // Suggested Movies
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Suggested Movies")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 20) {
                            ForEach(viewModel.discoverModel, id: \.self) { movie in
                                Button {
                                    selectedMovie = movie
                                } label: {
                                    VStack {
                                        WebImage(url: URL(string: Constant.imageURL + (movie.poster_path ?? "")))
                                            .resizable()
                                            .placeholder(Image("placeholder"))
                                            .scaledToFill()
                                            .frame(height: 250)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        
                                        Text(movie.title ?? "")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    // Search Results
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(viewModel.searchResults, id: \.self) { movie in
                            Button {
                                selectedMovie = movie
                            } label: {
                                VStack {
                                    WebImage(url: URL(string: Constant.imageURL + (movie.poster_path ?? "")))
                                        .resizable()
                                        .placeholder(Image("placeholder"))
                                        .scaledToFill()
                                        .frame(height: 250)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    Text(movie.title ?? "")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .background(Color.black)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedMovie) { movie in
            ZStack(alignment: .topTrailing) {
                MovieDetailView(movie: movie, viewModel: HomeViewModel())
                
                Button {
                    selectedMovie = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .padding(10)
                        .scaleEffect(0.9)
                }
                .padding(.top, 15)
                .padding(.trailing, 15)
                .zIndex(1)
            }
            .background(Color.black)
            .ignoresSafeArea()
        }
    }
}

struct RatingView: View {
    
    var rating: Float
    
    var body: some View {
        HStack(spacing: 4, content: {
            ForEach(0..<5, id: \.self) { index in
                let indie = Float(index)
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(indie <= (rating/2.5) ? .yellow : .gray.opacity(0.5))
                
            }
        })
    }
}

#Preview {
    SearchContentView()
}
