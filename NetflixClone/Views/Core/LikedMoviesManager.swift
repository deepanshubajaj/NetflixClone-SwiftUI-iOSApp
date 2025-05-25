//
//  LikedMoviesManager.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 23/05/25.
//

import Foundation

class LikedMoviesManager {
    static let shared = LikedMoviesManager()
    private let key = "likedMovies"
    
    func getLikedMovies() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }
    
    func isLiked(movieTitle: String) -> Bool {
        getLikedMovies().contains(movieTitle)
    }
    
    func like(movieTitle: String) {
        var liked = getLikedMovies()
        if !liked.contains(movieTitle) {
            liked.append(movieTitle)
            UserDefaults.standard.set(liked, forKey: key)
        }
    }
    
    func unlike(movieTitle: String) {
        var liked = getLikedMovies()
        liked.removeAll { $0 == movieTitle }
        UserDefaults.standard.set(liked, forKey: key)
    }
} 
