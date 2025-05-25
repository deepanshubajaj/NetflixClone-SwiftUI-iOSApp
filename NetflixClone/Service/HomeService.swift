//
//  HomeServiceManager.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 22/05/25.
//

import Foundation
import Combine

protocol HomeServiceDelegate {
    func apiTrendingMovie(with url: URL) -> Future<MovieTitleResponse,Error>
    func apiTrendingTv(with url: URL) -> Future<MovieTitleResponse,Error>
    func apiPopular(with url: URL) -> Future<MovieTitleResponse,Error>
    func apiUpComing(with url: URL) -> Future<MovieTitleResponse,Error>
    func apiTopRated(with url: URL) -> Future<MovieTitleResponse,Error>
    func apiYoutubeUrl(url: URL) -> Future<YoutubeResponse, Error>
}

final class HomeService : HomeServiceDelegate {
    private let serviceManager: ServiceManager<MovieTitleResponse>
    
    init(serviceManager: ServiceManager<MovieTitleResponse> = ServiceManager()) {
        self.serviceManager = serviceManager
    }
    
    func apiTrendingMovie(with url: URL) -> Future<MovieTitleResponse, Error> {
        print("Fetching trending movies from: \(url)")
        return serviceManager.handlerRequestPublisher(url: url)
    }
    
    func apiTrendingTv(with url: URL) -> Future<MovieTitleResponse, Error> {
        print("Fetching trending TV from: \(url)")
        return serviceManager.handlerRequestPublisher(url: url)
    }
    
    func apiPopular(with url: URL) -> Future<MovieTitleResponse, Error> {
        print("Fetching popular movies from: \(url)")
        return serviceManager.handlerRequestPublisher(url: url)
    }
    
    func apiUpComing(with url: URL) -> Future<MovieTitleResponse, Error> {
        print("Fetching upcoming movies from: \(url)")
        return serviceManager.handlerRequestPublisher(url: url)
    }
    
    func apiTopRated(with url: URL) -> Future<MovieTitleResponse, Error> {
        print("Fetching top rated movies from: \(url)")
        return serviceManager.handlerRequestPublisher(url: url)
    }
    
    func apiYoutubeUrl(url: URL) -> Future<YoutubeResponse, any Error> {
        print("Fetching YouTube data from: \(url)")
        let router = ServiceManager<YoutubeResponse>()
        return router.handlerRequestPublisher(url: url)
    }
}
