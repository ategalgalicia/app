//
//  Created by Michele Restuccia on 8/11/25.
//

import Foundation
import AtegalCore

#if os(Android)
import SkipFuseUI
#endif

@Observable
@MainActor
class HomeDataSource {
    var centers: [Center] = []
    var centerSelected: Center? = nil
    var categorySelected: Center.Category? = nil
    var activitySelected: Center.Category.Activity? = nil
        
    init(apiClient: AtegalAPIClient) {
        self.centers = apiClient.fetchCenters()
    }
}
