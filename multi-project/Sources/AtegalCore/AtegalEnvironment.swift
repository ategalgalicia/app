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
                return "https://ategal.com/wp-json/wp/v2/"
            }
        }()
        return URL(string: urlString)!
    }
}

// MARK: MockGoBarberEnvironment

struct MockAtegalEnvironment: Environment, Sendable {
    var baseURL: URL = URL(
        string: "https://ategal.com/wp-json/wp/v2/"
    )!
}
