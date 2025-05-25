//
//  MovieResponseModel.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 22/05/25.
//

import Foundation

struct MovieTitleResponse: Codable, Hashable {
    var results : [MovieDetailModel]
}

struct MovieDetailModel: Codable, Hashable, Identifiable {
    var id: Int?
    var overview: String?
    var title: String?
    var original_title: String?
    var original_language: String?
    var poster_path: String?
    var release_date: String?
    var video: Bool?
    var vote_average: Float?
    var popularity: Double?
    var media_type: String?
    var cast: [Cast]?
    var adult: Bool?
    var genres: [Genre]?
    var backdrop_path: String?
    var genre_ids: [Int]?
    var vote_count: Int?
    
    // Add a computed property for Identifiable
    var identifier: String {
        return "\(id ?? 0)"
    }
}

struct Genre: Codable, Hashable {
    var id: Int?
    var name: String?
}

struct Cast: Codable, Hashable {
    var id: Int?
    var name: String?
    var character: String?
    var profile_path: String?
}

struct CreditsResponse: Codable {
    var cast: [Cast]
}

struct UserList: Codable, Hashable {
    var movies: [MovieDetailModel]
    
    static var shared: UserList {
        get {
            if let data = UserDefaults.standard.data(forKey: "savedMovies"),
               let decodedList = try? JSONDecoder().decode(UserList.self, from: data) {
                return decodedList
            }
            return UserList(movies: [])
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: "savedMovies")
            }
        }
    }
    
    mutating func addMovie(_ movie: MovieDetailModel) {
        if !movies.contains(where: { $0.id == movie.id }) {
            movies.append(movie)
            UserList.shared = self
        }
    }
    
    mutating func removeMovie(_ movie: MovieDetailModel) {
        movies.removeAll { $0.id == movie.id }
        UserList.shared = self
    }
    
    func contains(_ movie: MovieDetailModel) -> Bool {
        movies.contains { $0.id == movie.id }
    }
}


