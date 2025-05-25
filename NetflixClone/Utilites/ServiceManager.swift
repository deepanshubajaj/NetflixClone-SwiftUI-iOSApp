//
//  ServiceManager.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 23/05/25.
//

import Foundation
import Combine

final class ServiceManager<T: Codable> {
    
    var cancellables = Set<AnyCancellable>()
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func handlerRequestPublisher(url: URL) -> Future<T,Error> {
        return Future<T, Error> { [weak self] promise in
            print("Making request to URL: \(url)")
            self?.networkManager.fetchRequest(type: T.self, url: url) { result in
                switch result {
                case .success(let models):
                    print("Successfully decoded response for URL: \(url)")
                    promise(.success(models))
                case .failure(let error):
                    print("Error fetching data from URL: \(url)")
                    print("Error details: \(error)")
                    promise(.failure(error))
                }
            }
        }
    }
}
