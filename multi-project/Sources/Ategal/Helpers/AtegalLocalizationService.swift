import Foundation
import RStudioKit

final class AtegalLocalizationService: LocalizationService, @unchecked Sendable {

    func localized(_ key: String) -> String {
        NSLocalizedString(key, bundle: .module, comment: "")
    }

    func l10n(_ key: String, arguments: [String]) -> String {
        String(format: localized(key), arguments: arguments)
    }
}
