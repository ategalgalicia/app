//
//  Created by Michele Restuccia on 25/7/25.
//

import Foundation

#if os(Android)
import FoundationNetworking
#endif

public protocol Environment: Sendable {
    var baseURL: URL { get }
}

public extension Environment {
    
    func createURLRequest(for endpoint: Endpoint) throws -> URLRequest {
        let path = routeURL(endpoint.path)
        guard
            let url = URL(string: path),
            url.scheme != nil,
            url.host != nil
        else {
            throw APIClientError.malformedURL
        }
        return URLRequest(url: url)
    }
}

private extension Environment {
    
    func routeURL(_ pathURL: String) -> String {
        baseURL.absoluteString + pathURL
    }
}
