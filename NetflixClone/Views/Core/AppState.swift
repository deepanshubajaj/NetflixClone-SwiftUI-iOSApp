//
//  TabBar.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 23/05/25.
//

import SwiftUI

class AppState: ObservableObject {
    enum Route {
        case none
        case sampleView
    }
    
    @Published var showWhoWatching: Bool = false
    @Published var activeRoute: Route = .none
}
