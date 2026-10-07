//
//  Created by Michele Restuccia on 1/12/25.
//

#if os(Android)
import SkipFirebaseCore
import SkipFirebaseAnalytics
import SkipFirebaseCrashlytics
#else
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics
#endif

public actor Tracking {
    public enum Event: Sendable {
        case appOpen
        case login(method: LoginMethod)
        case logout
        case tabSelected(tab: String)
        case tutorialComplete
        case postOpen(title: String)
        case activityContactOpen(centerName: String)
        case homeAction(destination: HomeDestination)
        case notificationTopicChanged(topic: PushTopic, enabled: Bool)

        public enum LoginMethod: String, Sendable {
            case google, apple
        }

        public enum HomeDestination: String, Sendable {
            case calendar, centers, activities, resources
        }

        fileprivate var name: String {
            switch self {
            case .appOpen: "app_open"
            case .login: "login"
            case .logout: "logout"
            case .tabSelected: "tab_selected"
            case .tutorialComplete: "tutorial_complete"
            case .postOpen: "post_open"
            case .activityContactOpen: "activity_contact_open"
            case .homeAction: "home_action"
            case .notificationTopicChanged: "notification_topic_changed"
            }
        }

        fileprivate var parameters: [String: String] {
            switch self {
            case .appOpen, .logout, .tutorialComplete:
                return [:]
            case .login(let method):
                return ["method": method.rawValue]
            case .tabSelected(let tab):
                return ["tab": tab]
            case .postOpen(let title):
                return ["post_title": title]
            case .activityContactOpen(let centerName):
                return ["center_name": centerName]
            case .homeAction(let destination):
                return ["destination": destination.rawValue]
            case .notificationTopicChanged(let topic, let enabled):
                return [
                    "topic": topic.rawValue,
                    "enabled": enabled ? "true" : "false"
                ]
            }
        }
    }
    
    public static func bootstrap() {
        FirebaseApp.configure()
    }
    
    public static func trackEvent(_ event: Event) {
        var eventParameters = event.parameters
        eventParameters[AnalyticsParameterSourcePlatform] = platformName
        Task(priority: .low) {
            Analytics.logEvent(event.name, parameters: eventParameters)
        }
    }
    
    private static var platformName: String {
        #if os(Android)
        return "android"
        #else
        return "ios"
        #endif
    }
}
