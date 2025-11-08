//
//  Created by Michele Restuccia on 8/11/25.
//

import Foundation

enum AtegalAPI: Endpoint {
    
    case getPosts
    
    var path: String {
        switch self {
        case .getPosts: "posts"
        }
    }
}
