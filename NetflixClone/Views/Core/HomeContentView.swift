//
//  ContentView.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 23/05/25.
//

import SwiftUI
import SDWebImageSwiftUI


struct HomeContentView: View {
    
    @ObservedObject private var viewModel : HomeViewModel
    @State private var showVideo = false
    @State private var selectedMovie: MovieDetailModel?
    @State private var youtubeItem: Item?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @StateObject private var webViewState = WebViewState()
    
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        UIScrollView.appearance().bounces = false
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.black.ignoresSafeArea()
                
                GeometryReader {
                    let size = $0.size
                    ScrollView{
                        VStack(spacing: 0){
                            headerView()
                                .padding(.horizontal,20)
                                .padding(.vertical,20)
                                .shimmering(active: viewModel.isloading, animation: .bouncy)
                            
                            listView(size: size)
                            
                            newsAndHotView()
                        }
                        .padding(.bottom,30)
                    }
                    .scrollIndicators(.hidden)
                    .refreshable {
                        do {
                            try await viewModel.manageHomeResponse()
                        } catch {
                            print("Failed to refresh home sections: \(error)")
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .onDisappear{UIScrollView.appearance().bounces = true}
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    HStack{
                        Image("netflix")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 20, height: 32)
                        Spacer()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack{
                        NavigationLink(
                            destination: SearchContentView()
                                .toolbar(.hidden, for: .tabBar)
                        ) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Color.white)
                                .frame(width: 20, height: 20)
                        }
                        Spacer()
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
                        .padding(.top, 25)
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
            .sheet(item: $selectedMovie) { movie in
                ZStack(alignment: .topTrailing) {
                    MovieDetailView(movie: movie, viewModel: viewModel)
                    
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
    
    @ViewBuilder
    private func headerView() -> some View {
        ZStack{
            VStack {
                TabView {
                    ForEach(viewModel.bannerMovies, id: \.self) { movie in
                        Button {
                            selectedMovie = movie
                        } label: {
                            WebImage(url: URL(string: Constant.imageURL + (movie.poster_path ?? "")))
                                .resizable()
                                .placeholder(Image("placeholder"))
                                .scaledToFill()
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay {
                                    ZStack(alignment: .bottom){
                                        LinearGradient(colors: [.black.opacity(0.1),.clear,.black.opacity(0.1),.black.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(.white, lineWidth: 1.0)
                                        HStack(spacing: 20){
                                            Button {
                                                print("Play button tapped for movie: \(movie.title ?? "Unknown")")
                                                selectedMovie = movie
                                                Task {
                                                    await fetchYoutubeVideo(for: movie)
                                                }
                                            } label: {
                                                topButtonView(type: .play, image: "play.fill", title: "Play")
                                            }
                                            .disabled(isLoading)
                                            
                                            if isLoading {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                    .scaleEffect(0.8)
                                            }
                                            
                                            Button {
                                                viewModel.toggleMovieInList(movie)
                                            } label: {
                                                topButtonView(
                                                    type: .add,
                                                    image: viewModel.isMovieInList(movie) ? "checkmark" : "plus",
                                                    title: viewModel.isMovieInList(movie) ? "Added" : "My List"
                                                )
                                            }
                                        }
                                        .padding(.horizontal,20)
                                        .padding(.bottom)
                                    }
                                }
                        }
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 500)
            }
        }
    }
    
    private func fetchYoutubeVideo(for movie: MovieDetailModel) async {
        isLoading = true
        errorMessage = nil
        
        print("Fetching video for movie: \(movie.title ?? "Unknown")")
        
        do {
            let item = try await viewModel.fetchYoutubeVideo(for: movie)
            print("Received YouTube item: \(String(describing: item))")
            youtubeItem = item
            
            if let videoID = item?.id.videoID {
                print("Video ID found: \(videoID)")
                showVideo = true
            } else {
                print("No video ID found in the response")
                errorMessage = "No trailer found."
            }
            
        } catch {
            print("Error fetching YouTube video: \(error)")
            errorMessage = "Failed to fetch trailer."
        }
        
        isLoading = false
    }
    
    @ViewBuilder
    private func listView(size: CGSize) -> some View {
        ForEach(viewModel.homeSection) { section in
            VStack(spacing:15){
                HStack{
                    Text(section.id.capitalizesFirst())
                        .foregroundStyle(Color.white)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .shimmering(active: viewModel.isloading, animation: .bouncy)
                    
                    if case .myList = section {
                        NavigationLink(destination: MyListView(viewModel: viewModel)) {
                            Text("See All")
                                .foregroundStyle(Color.white)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(.horizontal,15)
                ScrollView(.horizontal) {
                    HStack(spacing: 12){
                        switch section {
                        case .trendingMovies(let movies):
                            ForEach(movies, id: \.self) { movie in
                                Button {
                                    selectedMovie = movie
                                } label: {
                                    imageView(size: size, url: movie.poster_path ?? "")
                                }
                            }
                        case .trendingTv(let tv):
                            ForEach(tv, id: \.self) { movie in
                                Button {
                                    selectedMovie = movie
                                } label: {
                                    imageView(size: size, url: movie.poster_path ?? "")
                                }
                            }
                        case .popular(model: let popular):
                            ForEach(popular, id: \.self) { movie in
                                Button {
                                    selectedMovie = movie
                                } label: {
                                    imageView(size: size, url: movie.poster_path ?? "")
                                }
                            }
                        case .upComing(let upComing):
                            ForEach(upComing, id: \.self) { movie in
                                Button {
                                    selectedMovie = movie
                                } label: {
                                    imageView(size: size, url: movie.poster_path ?? "")
                                }
                            }
                        case .topRate(let topRated):
                            ForEach(topRated, id: \.self) { movie in
                                Button {
                                    selectedMovie = movie
                                } label: {
                                    imageView(size: size, url: movie.poster_path ?? "")
                                }
                            }
                        case .myList(let myList):
                            ForEach(myList, id: \.self) { movie in
                                Button {
                                    selectedMovie = movie
                                } label: {
                                    imageView(size: size, url: movie.poster_path ?? "")
                                }
                            }
                        }
                    }
                    .padding(.horizontal,15)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
    
    private func imageView(size : CGSize, url: String) -> some View {
        WebImage(url: URL(string: Constant.imageURL+url))
            .placeholder(Image("placeholder"))
            .resizable()
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(width: size.width/2.8,height: isiPad() ? size.height/2.8 : size.height/3.5)
            .background(RoundedRectangle(cornerRadius: 10))
            .shimmering(active: viewModel.isloading, animation: .bouncy)
    }
    
    @ViewBuilder
    private func topButtonView(type: TopButtonType, image: String , title: String) -> some View {
        HStack(spacing: 12){
            Image(systemName: image)
                .fontWeight(.bold)
                .foregroundStyle(type == .play ? .black : .white)
                .frame(width: 15, height: 15)
            Text(title)
                .foregroundStyle(type == .play ? .black : .white)
                .font(.headline)
                .fontWeight(.semibold)
            
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical,10)
        .background(type == .play ? .white : .white.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
    
    @ViewBuilder
    private func newsAndHotView() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("News & Hot")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.newsAndHotMovies, id: \.self) { movie in
                        Button {
                            selectedMovie = movie
                        } label: {
                            VStack(alignment: .leading) {
                                WebImage(url: URL(string: Constant.imageURL + (movie.poster_path ?? "")))
                                    .resizable()
                                    .placeholder(Image("placeholder"))
                                    .scaledToFill()
                                    .frame(width: 150, height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Text(movie.title ?? "")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    .lineLimit(2)
                                    .frame(width: 150)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
}

#Preview {
    HomeContentView()
}
