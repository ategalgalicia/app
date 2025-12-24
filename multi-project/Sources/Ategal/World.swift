//
//  Created by Michele Restuccia on 28/10/25.
//

import Foundation
import AtegalCore
import SkipFuse; import SkipFuseUI

struct World {
    
    let wpApiClient: WPAPIClient
    let gistApiClient: GistAPIClient
    let appVersion: String
    
    init() {
        self.wpApiClient = WPAPIClient()
        self.gistApiClient = GistAPIClient()
        self.appVersion = "Versión \(World.marketingVersion) (\(World.buildNumber))"
    }
}

// MARK: AppVersion

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
