//
//  GamesContentView.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 23/05/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct MyListView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(viewModel.userList.movies, id: \.self) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie, viewModel: viewModel)) {
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
        .background(Color.black)
        .navigationTitle("My List")
        .navigationBarTitleDisplayMode(.inline)
    }
} 
