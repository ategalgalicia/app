//
//  Created by Michele Restuccia on 2/12/25.
//

import Foundation

public extension String {

    var localized: String {
        NSLocalizedString(self, bundle: .module, comment: "")
    }
    
    var capitalizedFirst: String {
        if isEmpty { return "" }
        var result = self
        result.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).uppercased())
        return result
    }
}
