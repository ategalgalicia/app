//
//  Created by Michele Restuccia on 28/10/25.
//

import Foundation
import AtegalCore
import Observation

#if os(Android)
import SkipFuse; import SkipFuseUI
#endif

@MainActor
@Observable
class World {
    
    let wpApiClient: WPAPIClient
    let gistApiClient: GistAPIClient
    
    let authManager: AuthManager
    let pushManager: PushManager
    
    let appVersion: String
    
    init() async throws {
        self.appVersion = "Versión \(World.marketingVersion) (\(World.buildNumber))"
        self.wpApiClient = WPAPIClient()
        self.gistApiClient = GistAPIClient()
        self.authManager = AuthManager()
        self.pushManager = PushManager()
    }
}

// MARK: - Extensions

private extension World {
    
    static var marketingVersion: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? ""
    }

    static var buildNumber: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? ""
    }
}
