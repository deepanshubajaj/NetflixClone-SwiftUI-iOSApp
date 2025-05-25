//
//  AirPlayButtonView.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 25/05/25.
//

import SwiftUI
import AVKit

struct AirPlayButtonView: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.activeTintColor = .white
        view.tintColor = .white
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}

