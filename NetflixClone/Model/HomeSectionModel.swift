//
//  HomeSectionModel.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 22/05/25.
//

import Foundation

enum HomeSection: Identifiable {
    case trendingMovies(model: [MovieDetailModel])
    case trendingTv(model: [MovieDetailModel])
    case popular(model: [MovieDetailModel])
    case upComing(model: [MovieDetailModel])
    case topRate(model: [MovieDetailModel])
    case myList(model: [MovieDetailModel])
    
    var id: String {
        // Return a unique identifier for each case
        switch self {
        case .trendingMovies:
            return "trending Movies"
        case .trendingTv:
            return "trending TV"
        case .popular:
            return "popular"
        case .upComing:
            return "upcoming"
        case .topRate:
            return "top rated"
        case .myList:
            return "my list"
        }
    }
}

extension HomeSection: Hashable {
    static func == (lhs: HomeSection, rhs: HomeSection) -> Bool {
        // Implement equality check based on your requirements
        switch (lhs, rhs) {
        case (.trendingMovies, .trendingMovies),
            (.trendingTv, .trendingTv),
            (.popular, .popular),
            (.upComing, .upComing),
            (.topRate, .topRate),
            (.myList, .myList):
            return true
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        // Use the id property for hashing
        hasher.combine(id)
    }
}

