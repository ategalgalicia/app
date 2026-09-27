//
//  Created by Michele Restuccia on 22/08/2026.
//

import Foundation
import Observation

#if os(iOS)
import UIKit
@preconcurrency import UserNotifications
import FirebaseMessaging
#else
import SkipUI
import SkipFuse
@preconcurrency import SkipFirebaseMessaging
#endif

// SKIP @bridge
@MainActor
@Observable
public class PushManager: NSObject, @preconcurrency UNUserNotificationCenterDelegate, @preconcurrency MessagingDelegate {

    private nonisolated(unsafe) let messaging: Messaging
    private nonisolated(unsafe) let notificationCenter = UNUserNotificationCenter.current()
    private var deeplinkHandler: DeeplinkHandler?

    public private(set) var isPushAuthorized = false
    
    #if os(iOS)
    private var registrationContinuation: CheckedContinuation<Void, Error>?
    private var apnsDeviceToken: Data?
    #endif
    
    #if os(Android)
    private static var pushPayloadHandler: ((String, String) -> Void)?
    #endif
    
    public override init() {
        messaging = Messaging.messaging()
        super.init()
        messaging.delegate = self
        notificationCenter.delegate = self
    }

    #if os(Android)
    /* SKIP @bridge */
    public static func create() -> PushManager {
        let manager = PushManager()
        pushPayloadHandler = { [weak manager] activity, query in
            manager?.receivePushPayload(activity, query: query)
        }
        return manager
    }

    /* SKIP @bridge */
    public static func didReceivePushPayload(_ activity: String, query: String) {
        // Bridge entry point invoked by Android's MainActivity.
        Task { @MainActor in
            pushPayloadHandler?(activity, query)
        }
    }

    #endif
    
    public func onReceiveDeeplink(_ handler: @escaping DeeplinkHandler) {
        deeplinkHandler = handler
    }
    
    @MainActor
    public func refreshUserStatus(_ status: UserStatus) async {
        do {
            switch status {
            case .logged:
                guard try await requestPushesAuthorization() else {
                    return
                }
                try await subscribe(to: .general)
            case .unlogged:
                await unsubscribeFromAllTopics()
            }
        } catch {
            print("Push status refresh failed: \(error)")
        }
    }
    
    @MainActor
    private func requestPushesAuthorization() async throws -> Bool {
        let settings = await notificationCenter.notificationSettings()
        isPushAuthorized = settings.authorizationStatus == .authorized
        guard settings.authorizationStatus != .denied else {
            return false
        }
        #if os(iOS)
        if apnsDeviceToken != nil {
            return true
        }
        let granted = try await notificationCenter.requestAuthorization(
            options: [.sound, .alert, .badge]
        )
        isPushAuthorized = granted
        guard granted else { return false }
        try await withCheckedThrowingContinuation { continuation in
            let continuation: CheckedContinuation<Void, Error> = continuation
            registrationContinuation = continuation
            UIApplication.shared.registerForRemoteNotifications()
        }
        return true
        #else
        let granted = try await notificationCenter.requestAuthorization(bridgedOptions: 7)
        isPushAuthorized = granted
        return granted
        #endif
    }
    
    public func hasPushAuthorization() async -> Bool {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    // MARK: - AppDelegate
    
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
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        _ = messaging.appDidReceiveMessage(notification.request.content.userInfo)
        return [.banner, .sound, .badge]
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        _ = messaging.appDidReceiveMessage(userInfo)
        guard let activity = userInfo["activity"] as? String, !activity.isEmpty else {
            return
        }
        receivePushPayload(activity, query: userInfo["query"] as? String)
    }
    #endif
    
    private func receivePushPayload(_ activity: String, query: String?) {
        deeplinkHandler?( DeeplinkPayload(activity: activity, query: query))
    }
    
    // MARK: - MessagingDelegate
    
    public func subscribe(to topic: PushTopic) async throws {
        #if os(iOS)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            messaging.subscribe(toTopic: topic.rawValue) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
        #else
        try await messaging.subscribe(toTopic: topic.rawValue)
        #endif
    }
    
    public func unsubscribe(from topic: PushTopic) async throws {
        #if os(iOS)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            messaging.unsubscribe(fromTopic: topic.rawValue) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
        #else
        try await messaging.unsubscribe(fromTopic: topic.rawValue)
        #endif
    }

    private func unsubscribeFromAllTopics() async {
        for topic in PushTopic.allCases {
            do {
                try await unsubscribe(from: topic)
            } catch {
                print("Push topic unsubscription failed: \(error)")
            }
        }
    }

    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {}
}
