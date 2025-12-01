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
    
    public static func bootstrap() {
        FirebaseApp.configure()
    }
    
    public static func trackEvent() {
        Task(priority: .low) {
            Analytics.logEvent("app_open", parameters: [
                AnalyticsParameterSourcePlatform: platformName
            ])
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
