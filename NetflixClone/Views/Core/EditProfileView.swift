//
//  EditProfileView.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 23/05/25.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    var profile: Profile
    @Binding var profiles: [Profile]
    @State private var name: String = ""
    @State private var selectedIcon: String = ""
    let allIcons: [String] = (0...50).map { $0 == 0 ? "DP" : "DP\($0)" }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Name", text: $name)
                }
                Section(header: Text("Icon")) {
                    let rows = Array(repeating: GridItem(.fixed(60), spacing: 12), count: 5)
                    ScrollView(.horizontal) {
                        LazyHGrid(rows: rows, spacing: 12) {
                            ForEach(allIcons, id: \.self) { icon in
                                Image(icon)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(selectedIcon == icon ? Color.red : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                if let idx = profiles.firstIndex(where: { $0.id == profile.id }) {
                    profiles[idx].name = name
                    profiles[idx].imageName = selectedIcon
                }
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                name = profile.name
                selectedIcon = profile.imageName
            }
        }
    }
} 
