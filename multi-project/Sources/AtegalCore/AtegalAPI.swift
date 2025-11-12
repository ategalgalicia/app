//
//  Created by Michele Restuccia on 8/11/25.
//

import Foundation

enum AtegalAPI: Endpoint {
    
    case getPosts
    case getCalendarEvents
    
    var path: String {
        switch self {
        case .getPosts: "wp-json/wp/v2/posts"
        case .getCalendarEvents: ""
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .getPosts:
            return nil
            
        case .getCalendarEvents:
            return [
                "post_type" : "tribe_events",
                "ical" : "1",
                "eventDisplay" : "list"
            ]
        }
    }
}
