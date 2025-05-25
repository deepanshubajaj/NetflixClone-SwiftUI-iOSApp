//
//  NetflixCloneApp.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 24/05/25.
//

import SwiftUI
import UserNotifications

@main
struct NetflixCloneApp: App {
    @StateObject var appState = AppState()
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        NotificationManager.shared.registerNotificationCategory()
        NotificationManager.shared.requestAuthorization()
        
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(appState)
                .onAppear {
                    NotificationDelegate.shared.appState = appState
                }
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    private override init() { super.init() }
    
    weak var appState: AppState?
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge, .list])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.content.categoryIdentifier == NotificationManager.generalCategoryIdentifier {
            print("🔔 Notification tapped — navigating to SampleView")
            DispatchQueue.main.async {
                self.appState?.activeRoute = .sampleView
            }
        }
        completionHandler()
    }
}
