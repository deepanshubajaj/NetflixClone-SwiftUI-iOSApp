//
//  SearchViewModel.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 22/05/25.
//

import Foundation
import Combine


final class SearchViewModel : ObservableObject {
    
    @Published var discoverModel: [MovieDetailModel] = []
    @Published var searchDetail: [MovieDetailModel] = []
    @Published var searchTxt: String = ""
    @Published var isLoading: Bool = false // shimmer effect for suggestion list
    @Published var isSearching: Bool = false // shimmer effect for during search data
    @Published var searchResults: [MovieDetailModel] = []
    
    private var serviceManger: SearchMangerDelegate
    
    init(serviceManger: SearchMangerDelegate = SearchManger()) {
        self.serviceManger = serviceManger
        Task{
            try await getDiscover()
        }
    }
    
    func searchMovies(query: String) async {
        guard !query.isEmpty else {
            await MainActor.run {
                searchResults = []
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let urlString = "\(Constant.baseURl)/search/movie?api_key=\(Constant.Api_Key)&query=\(encodedQuery)"
            
            guard let url = URL(string: urlString) else { return }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(MovieTitleResponse.self, from: data)
            
            await MainActor.run {
                searchResults = response.results
                isLoading = false
            }
        } catch {
            print("Error searching movies: \(error)")
            await MainActor.run {
                searchResults = []
                isLoading = false
            }
        }
    }
}

// MARK: - API Response Handler
extension SearchViewModel {
    
    @MainActor
    func getDiscover() async throws {
        isLoading = true
        guard let url = URL(string: Constant.discoverUrl) else {return}
        let result = try await serviceManger.getDisCover(url: url)
        discoverModel = result
        isLoading = false
    }
    
    @MainActor
    func getSearch() async throws {
        isSearching = true
        guard let quary = searchTxt.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let url = URL(string: Constant.searchUrl+"&query="+quary) else {return }
        let result = try await serviceManger.getSearch(url: url)
        searchDetail = result
        isSearching = false
    }
}
