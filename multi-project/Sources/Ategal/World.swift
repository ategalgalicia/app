//
//  Created by Michele Restuccia on 28/10/25.
//

import Foundation
import AtegalCore
import SkipFuse; import SkipFuseUI

struct World {
    
    let apiClient: AtegalAPIClient
    let centers: [Center]
    init() {
        self.apiClient = .init(environment: .init(host: .production))
        self.centers = apiClient.fetchCenters()
    }
}
