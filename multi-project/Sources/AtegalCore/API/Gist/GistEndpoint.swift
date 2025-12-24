//
//  Created by Michele Restuccia on 27/10/25.
//

import Foundation

enum GistEndpoint: Endpoint {
    
    case getCenters
    
    var path: String {
        switch self {
        case .getCenters: "1090045bd5d98f9a692d4426b7f9f48e/raw/"
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .getCenters:
            return [
                "t": Int(Date().timeIntervalSince1970)
            ]
        }
    }
}


