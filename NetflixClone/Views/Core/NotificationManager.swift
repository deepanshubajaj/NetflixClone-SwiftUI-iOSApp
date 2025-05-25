//
//  NotificationManager.swift
//  NetflixClone
//
//  Created by Deepanshu Bajaj on 24/05/25.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    static let generalCategoryIdentifier = "GENERAL_NOTIFICATION_CATEGORY"
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
    
    func registerNotificationCategory() {
        let category = UNNotificationCategory(
            identifier: NotificationManager.generalCategoryIdentifier,
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
        print("✅ Notification category registered.")
    }
    
    func sendNotification(title: String, body: String, imageName: String? = nil, imageExtension: String = "jpg") {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = NotificationManager.generalCategoryIdentifier
        
        // Add image attachment if provided
        if let imageName = imageName {
            var imageURL: URL?
            
            // First try with subdirectory
            imageURL = Bundle.main.url(forResource: imageName, withExtension: imageExtension, subdirectory: "NotificationAssets")
            
            // If not found, try without subdirectory
            if imageURL == nil {
                imageURL = Bundle.main.url(forResource: imageName, withExtension: imageExtension)
            }
            
            if let imageURL = imageURL {
                print("[NotificationManager] Found image URL: \(imageURL)")
                do {
                    let attachment = try UNNotificationAttachment(identifier: "image", url: imageURL, options: nil)
                    content.attachments = [attachment]
                    print("[NotificationManager] Successfully attached image")
                } catch {
                    print("❌ Failed to attach image: \(error)")
                }
            } else {
                print("[NotificationManager] ❌ Image not found in bundle for name: \(imageName).\(imageExtension)")
            }
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            } else {
                print("✅ Notification scheduled")
            }
        }
    }
}
