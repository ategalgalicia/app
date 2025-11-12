//
//  Created by Michele Restuccia on 27/10/25.
//

import Foundation

public struct AtegalEnvironment: Environment, Sendable {
    
    public let host: Host
    public enum Host: Int, CaseIterable, Sendable, Equatable {
        case production
    }
    
    public init(host: Host) {
        self.host = host
    }
    
    public var baseURL: URL {
        let urlString: String = {
            switch host {
            case .production:
                return "https://www.ategal.com/"
            }
        }()
        return URL(string: urlString)!
    }
}
//let url = URL(string: "https://ategal.com/?post_type=tribe_events&ical=1&eventDisplay=list")!
