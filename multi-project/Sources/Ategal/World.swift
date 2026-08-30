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
        self.appVersion = "\(World.marketingVersion) (\(World.buildNumber))"
        self.wpApiClient = WPAPIClient()
        self.gistApiClient = GistAPIClient()
        self.authManager = AuthManager()
        #if os(Android)
        self.pushManager = PushManager.create()
        #else
        self.pushManager = PushManager()
        #endif
    }
}

// MARK: - Extensions

private extension World {
    static let marketingVersion = bundleValue(for: "CFBundleShortVersionString")
    static let buildNumber = bundleValue(for: "CFBundleVersion")
    private static func bundleValue(for key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
    }
}
