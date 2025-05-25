//
//  WhoWatching.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 23/05/25.
//

import SwiftUI

struct Profile: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var imageName: String
    var isChildren: Bool
}

class ProfileManager: ObservableObject {
    @Published var profiles: [Profile] {
        didSet { saveProfiles() }
    }
    init() { self.profiles = Self.loadProfiles() }
    static func loadProfiles() -> [Profile] {
        if let data = UserDefaults.standard.data(forKey: "profiles"),
           let decoded = try? JSONDecoder().decode([Profile].self, from: data) {
            return decoded
        }
        return [
            Profile(id: UUID(), name: "DEEPANSHU", imageName: "DP", isChildren: false),
            Profile(id: UUID(), name: "Family", imageName: "DP49", isChildren: false),
            Profile(id: UUID(), name: "Extra", imageName: "DP48", isChildren: false),
            Profile(id: UUID(), name: "Other", imageName: "DP47", isChildren: false),
            Profile(id: UUID(), name: "Children", imageName: "DP50", isChildren: true)
        ]
    }
    func saveProfiles() {
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: "profiles")
        }
    }
}

struct WhoWatching: View {
    @ObservedObject var profileManager = ProfileManager()
    @State private var showEditSheet = false
    @State private var selectedProfile: Profile? = nil
    @State private var isEditing = false
    @State private var showLoader = false
    @EnvironmentObject var appState: AppState
    var onProfileSelected: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Text("Who's Watching?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button("Edit") {
                        isEditing = true
                    }
                    .foregroundColor(.white)
                }
                .padding(.top, 40)
                Spacer()
                LazyVGrid(columns: [GridItem(.fixed(120)), GridItem(.fixed(120))], spacing: 16) {
                    ForEach(profileManager.profiles.filter { !$0.isChildren }) { profile in
                        ZStack(alignment: .topTrailing) {
                            VStack {
                                Image(profile.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                Text(profile.name)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            if isEditing {
                                Button(action: {
                                    selectedProfile = profile
                                    showEditSheet = true
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                        .background(Color.white.opacity(0.8))
                                        .clipShape(Circle())
                                        .padding(4)
                                }
                            }
                        }
                        .onTapGesture {
                            if !isEditing {
                                UserDefaults.standard.set(profile.id.uuidString, forKey: "selectedProfileId")
                                showLoader = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    appState.showWhoWatching = false
                                    showLoader = false
                                    onProfileSelected?()
                                }
                            }
                        }
                    }
                }
                if let childrenProfile = profileManager.profiles.first(where: { $0.isChildren }) {
                    ZStack(alignment: .topTrailing) {
                        VStack {
                            Image(childrenProfile.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            Text(childrenProfile.name)
                                .foregroundColor(.white)
                        }
                        if isEditing {
                            Button(action: {
                                selectedProfile = childrenProfile
                                showEditSheet = true
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.red)
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(Circle())
                                    .padding(4)
                            }
                        }
                    }
                    .padding(.top, 16)
                    .onTapGesture {
                        if !isEditing {
                            UserDefaults.standard.set(childrenProfile.id.uuidString, forKey: "selectedProfileId")
                            showLoader = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                appState.showWhoWatching = false
                                showLoader = false
                                onProfileSelected?()
                            }
                        }
                    }
                }
                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
            .sheet(item: $selectedProfile, onDismiss: { isEditing = false }) { profile in
                EditProfileView(
                    profile: profile,
                    profiles: $profileManager.profiles
                )
            }
            if showLoader {
                Color.black.opacity(0.8).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                    .scaleEffect(2)
            }
        }
    }
}

#Preview {
    WhoWatching()
} 
