//
//  Constant.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 24/05/25.
//

import Foundation

struct Constant {
    static let Api_Key = EnvNetflixClone.TMDB_API_KEY
    static let baseURl = EnvNetflixClone.TMDB_BaseUrl
    static let imageURL = EnvNetflixClone.TMDB_ImageUrl
    
    // API Endpoints
    static let popularUrl = "\(baseURl)/movie/popular?api_key=\(Api_Key)"
    static let trandingMovie = "\(baseURl)/trending/movie/day?api_key=\(Api_Key)"
    static let trendingTv = "\(baseURl)/trending/tv/day?api_key=\(Api_Key)"
    static let getUpComing = "\(baseURl)/movie/upcoming?api_key=\(Api_Key)"
    static let getTopRated = "\(baseURl)/movie/top_rated?api_key=\(Api_Key)"
    static let discoverUrl = "\(baseURl)/discover/movie?api_key=\(Api_Key)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_watch_monetization_types=flatrate"
    static let searchUrl = "\(baseURl)/search/movie?api_key=\(Api_Key)"
    
    // YouTube API
    static let youtube_Api_key = EnvNetflixClone.YOUTUBE_API_KEY
    static let youtube_BaseUrl = EnvNetflixClone.YouTUBE_BaseUrl
}
