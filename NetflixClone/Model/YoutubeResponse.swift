//
//  YoutubeResponse.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 23/05/25.
//

import Foundation


struct YoutubeResponse: Codable {
    let items: [Item]
}

// MARK: - Item
struct Item: Codable {
    let id: ID
}

// MARK: - ID
struct ID: Codable {
    let kind, videoID: String
    
    enum CodingKeys: String, CodingKey {
        case kind
        case videoID = "videoId"
    }
}

struct PreviewModel {
    let title: String
    let item: URL?
    let overView: String
}
