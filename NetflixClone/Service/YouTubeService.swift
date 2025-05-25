//
//  YouTubeService.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 25/05/25.
//

import Foundation

struct YouTubeVideo: Identifiable, Codable {
    let id: String
    let title: String
    let thumbnail: String
    let channelTitle: String
    let publishedAt: String
}

class YouTubeService {
    private let apiKey = EnvNetflixClone.YOUTUBE_API_KEY
    private let baseURL = EnvNetflixClone.YouTUBE_Service_BaseUrl
    
    func fetchVideos(query: String, completion: @escaping ([YouTubeVideo]) -> Void) {
        guard let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?part=snippet&maxResults=20&q=\(queryEncoded)&type=video&key=\(apiKey)") else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching videos: \(error)")
                completion([])
                return
            }
            
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(YouTubeResponse.self, from: data)
                let videos = response.items.map { item -> YouTubeVideo in
                    return YouTubeVideo(
                        id: item.id.videoId,
                        title: item.snippet.title,
                        thumbnail: item.snippet.thumbnails.high.url,
                        channelTitle: item.snippet.channelTitle,
                        publishedAt: item.snippet.publishedAt
                    )
                }
                DispatchQueue.main.async {
                    completion(videos)
                }
            } catch {
                print("Error decoding response: \(error)")
                completion([])
            }
        }.resume()
    }
}

struct YouTubeResponse: Codable {
    let items: [YouTubeItem]
}

struct YouTubeItem: Codable {
    let id: YouTubeId
    let snippet: YouTubeSnippet
}

struct YouTubeId: Codable {
    let videoId: String
}

struct YouTubeSnippet: Codable {
    let title: String
    let thumbnails: YouTubeThumbnails
    let channelTitle: String
    let publishedAt: String
}

struct YouTubeThumbnails: Codable {
    let high: YouTubeThumbnail
}

struct YouTubeThumbnail: Codable {
    let url: String
}
