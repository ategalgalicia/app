//
//  Created by Michele Restuccia on 8/10/26.
//

import Foundation
import RStudioKit
import SwiftUI

private enum AtegalResources {
    static let bundle: Foundation.Bundle = .module
}

public extension Image {
    init(ategal name: String) {
        self.init(name, bundle: AtegalResources.bundle)
    }
}

public extension String {

    var localized: String {
        AtegalResources.bundle.localizedString(forKey: self, value: nil, table: nil)
    }
}

final class AtegalLocalizationService: LocalizationService, @unchecked Sendable {

    func localized(_ key: String) -> String {
        AtegalResources.bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    func l10n(_ key: String, arguments: [String]) -> String {
        String(format: localized(key), arguments: arguments)
    }
}
