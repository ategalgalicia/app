//
//  Created by Michele Restuccia on 22/08/2026.
//

import Foundation

#if os(iOS)
import UIKit
import UserNotifications
import FirebaseMessaging
#else
@preconcurrency import SkipFirebaseMessaging
import SkipUI
#endif

// SKIP @bridge
@MainActor
public class PushManager: NSObject, UNUserNotificationCenterDelegate, @preconcurrency MessagingDelegate {
    
    private static let generalTopic = "general"
    
    private nonisolated(unsafe) let messaging: Messaging
    private nonisolated(unsafe) let notificationCenter = UNUserNotificationCenter.current()
    
    #if os(iOS)
    private var registrationContinuation: CheckedContinuation<Void, Error>?
    private var apnsDeviceToken: Data?
    #endif
    
    public override init() {
        messaging = Messaging.messaging()
        super.init()
        messaging.delegate = self
        #if os(iOS)
        notificationCenter.delegate = self
        #endif
    }
    
    @MainActor
    public func refreshUserStatus(_ status: UserStatus) async {
        do {
            switch status {
            case .logged:
                try await requestPushesAuthorization()
                try await subscribeToGeneralTopic()
            case .unlogged:
                try await unsubscribeFromGeneralTopic()
            }
        } catch {
            print("Push status refresh failed: \(error)")
        }
    }
    
    @MainActor
    private func requestPushesAuthorization() async throws {
        #if os(iOS)
        if apnsDeviceToken != nil {
            return
        }
        _ = try? await notificationCenter.requestAuthorization(
            options: [.sound, .alert, .badge]
        )
        try await withCheckedThrowingContinuation { continuation in
            let continuation: CheckedContinuation<Void, Error> = continuation
            registrationContinuation = continuation
            UIApplication.shared.registerForRemoteNotifications()
        }
        #else
        _ = try await notificationCenter.requestAuthorization(bridgedOptions: 7)
        #endif
    }
    
    @MainActor
    public func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        #if os(iOS)
        apnsDeviceToken = deviceToken
        messaging.apnsToken = deviceToken
        registrationContinuation?.resume()
        registrationContinuation = nil
        #endif
    }
    
    @MainActor
    public func didFailToRegisterForRemoteNotifications(_ error: Error) {
        #if os(iOS)
        registrationContinuation?.resume(throwing: error)
        registrationContinuation = nil
        #endif
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    #if os(iOS)
    nonisolated public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }
    #endif
    
    // MARK: - MessagingDelegate
    
    private func subscribeToGeneralTopic() async throws {
        #if os(iOS)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            messaging.subscribe(toTopic: Self.generalTopic) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
        #else
        try await messaging.subscribe(toTopic: Self.generalTopic)
        #endif
    }
    
    @MainActor
    private func unsubscribeFromGeneralTopic() async throws {
        #if os(iOS)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            messaging.unsubscribe(fromTopic: Self.generalTopic) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
        #else
        try await messaging.unsubscribe(fromTopic: Self.generalTopic)
        #endif
    }
}
