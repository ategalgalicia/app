//
//  Created by Michele Restuccia on 27/10/25.
//

import Foundation

public typealias Token = String

public class AtegalAPIClient: APIClient, @unchecked Sendable {
    
    var authToken: Token?
    
    public init(
        environment: AtegalEnvironment,
        networkFetcher: APIClientFetcher? = nil
    ) {
        super.init(environment: environment, fetcher: networkFetcher)
        customizeRequest = { [weak self] urlRequest in
            var mutableRequest = urlRequest
            if let token = self?.authToken {
                mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            return mutableRequest
        }
    }
}
