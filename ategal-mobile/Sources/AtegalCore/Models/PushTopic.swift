//
//  Created by Michele Restuccia on 28/08/2026.
//

import Foundation

public enum PushTopic: String, Codable, Identifiable, CaseIterable, Sendable {
    case general, santiago, acoruna, ferrol, lalin, monterroso, ourense, padron, vigo
    public var id: String { rawValue }
}
