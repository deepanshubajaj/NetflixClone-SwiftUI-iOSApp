//
//  TabBar.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 22/05/25.
//

import SwiftUI

struct TabBar: View {
    var body: some View {
        TabView {
            HomeContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            GamesContentView()
                .tabItem {
                    Image(systemName: "gamecontroller")
                    Text("Games")
                }
                .tag(1)
            
            NewHotView()
                .tabItem {
                    Image(systemName: "play.rectangle")
                    Text("New & Hot")
                }
                .tag(2)
            
            SampleView()
                .tabItem {
                    Image(systemName: "person.crop.square")
                    Text("My Netflix")
                }
                .tag(3)
        }
    }
}

#Preview {
    TabBar()
}
