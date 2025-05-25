//
//  NetworkManager.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 23/05/25.
//

import Foundation
import UIKit

enum APIError: Error {
    case BadUrl
    case NoData
    case DecodingError
    case NetworkError(String)
    case InvalidResponse(Int)
}

protocol APIHandlerDelegate {
    func fetchData(url: URL, completion: @escaping(Result<Data,APIError>) -> Void)
}

protocol ResponseHandlerDelegate {
    func fetchModel<T: Codable>(type: T.Type, data: Data, completion: (Result<T,APIError>) -> Void)
}

final class NetworkManager {
    let apiHandler: APIHandlerDelegate
    let responseHandler: ResponseHandlerDelegate
    
    init(apiHandler: APIHandlerDelegate = APIHandler(), responseHandler: ResponseHandlerDelegate = ResponseHandler()) {
        self.apiHandler = apiHandler
        self.responseHandler = responseHandler
    }
    
    func fetchRequest<T: Codable>(type: T.Type, url: URL, completion: @escaping(Result<T, APIError>) -> Void) {
        apiHandler.fetchData(url: url) { result in
            switch result {
            case .success(let data):
                self.responseHandler.fetchModel(type: type, data: data, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

final class APIHandler: APIHandlerDelegate {
    private let session: URLSession
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 2.0
    private var activeTasks: [URL: URLSessionDataTask] = [:]
    private let queue = DispatchQueue(label: "com.netflixclone.networkmanager")
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        // Optimize connection settings
        configuration.httpShouldUsePipelining = false
        configuration.httpMaximumConnectionsPerHost = 1
        configuration.connectionProxyDictionary = nil
        
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchData(url: URL, completion: @escaping (Result<Data, APIError>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // Check if there's already an active task for this URL
            if self.activeTasks[url] != nil {
                print("Task already in progress for URL: \(url)")
                return
            }
            
            print("Making request to URL: \(url)")
            self.fetchDataWithRetry(url: url, retryCount: 0, completion: completion)
        }
    }
    
    private func fetchDataWithRetry(url: URL, retryCount: Int, completion: @escaping (Result<Data, APIError>) -> Void) {
        print("Fetching data from URL: \(url) (Attempt \(retryCount + 1)/\(maxRetries))")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            self?.queue.async {
                // Remove the task from active tasks
                self?.activeTasks[url] = nil
                
                if let error = error {
                    print("Network Error: \(error.localizedDescription)")
                    if retryCount < self?.maxRetries ?? 0 {
                        print("Retrying request in \(self?.retryDelay ?? 2.0) seconds...")
                        DispatchQueue.global().asyncAfter(deadline: .now() + (self?.retryDelay ?? 2.0)) {
                            self?.fetchDataWithRetry(url: url, retryCount: retryCount + 1, completion: completion)
                        }
                        return
                    }
                    completion(.failure(.NetworkError(error.localizedDescription)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response type")
                    completion(.failure(.InvalidResponse(0)))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("Invalid status code: \(httpResponse.statusCode)")
                    if let data = data, let errorString = String(data: data, encoding: .utf8) {
                        print("Error response: \(errorString)")
                    }
                    if (500...599).contains(httpResponse.statusCode), retryCount < (self?.maxRetries ?? 0) {
                        print("Retrying request in \(self?.retryDelay ?? 2.0) seconds...")
                        DispatchQueue.global().asyncAfter(deadline: .now() + (self?.retryDelay ?? 2.0)) {
                            self?.fetchDataWithRetry(url: url, retryCount: retryCount + 1, completion: completion)
                        }
                        return
                    }
                    completion(.failure(.InvalidResponse(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    completion(.failure(.NoData))
                    return
                }
                
                print("Request succeeded. Status code: \(httpResponse.statusCode)")
                completion(.success(data))
            }
        }
        
        // Store the task
        queue.async {
            self.activeTasks[url] = task
        }
        
        task.resume()
    }
}

final class ResponseHandler: ResponseHandlerDelegate {
    func fetchModel<T: Codable>(type: T.Type, data: Data, completion: (Result<T, APIError>) -> Void) {
        do {
            let decoded = try JSONDecoder().decode(type.self, from: data)
            completion(.success(decoded))
        } catch {
            print("Decoding error: \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Key '\(key)' not found: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Type '\(type)' mismatch: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value of type '\(type)' not found: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error: \(decodingError)")
                }
            }
            completion(.failure(.DecodingError))
        }
    }
}
