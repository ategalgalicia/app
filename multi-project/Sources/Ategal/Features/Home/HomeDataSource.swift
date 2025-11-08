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
    var centers: [AtegalCore.Center] = []
    var centerSelected: AtegalCore.Center? = nil
    var categorySelected: AtegalCore.Category? = nil
    var activitySelected: AtegalCore.Activity? = nil
    
    init() {
        self.centers = [
            readFromBundle("santiago"),
            readFromBundle("coruna"),
            readFromBundle("ferrol"),
            readFromBundle("ourense"),
            readFromBundle("padron"),
            readFromBundle("vigo")
        ]
    }
    
    private func readFromBundle(_ center: String) -> AtegalCore.Center {
        let url = Bundle.module.url(forResource: center, withExtension: "json")
        if url != nil {
            logger.info("Reading JSON for \(center)")
        } else {
            logger.info("Reading JSON failed no URL")
        }
        guard let url,
              let json = try? Data(contentsOf: url, options: .mappedIfSafe),
              let preferences = try? JSONDecoder().decode(AtegalCore.Center.self, from: json) else {
            fatalError()
        }
        return preferences
    }
    
    /// For Preview
    static func mock() -> HomeDataSource {
        HomeDataSource()
    }
}
