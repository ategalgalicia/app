//
//  Created by Michele Restuccia on 28/08/2026.
//

import Foundation

public enum PushTopic: String, Codable, Identifiable, CaseIterable, Sendable {
    case general, santiago, acoruna, ferrol, lalin, monterroso, ourense, padron, vigo
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .general: "General"
        case .santiago: "Santiago de Compostela"
        case .acoruna: "A Coruña"
        case .ferrol: "Ferrol"
        case .lalin: "Lalín"
        case .monterroso: "Monterroso"
        case .ourense: "Ourense"
        case .padron: "Padrón"
        case .vigo: "Vigo"
        }
    }
}
