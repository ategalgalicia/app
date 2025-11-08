//
//  Created by Michele Restuccia on 27/10/25.
//

import Foundation

public class AtegalAPIClient: APIClient, @unchecked Sendable {
    
    public init(
        environment: AtegalEnvironment,
        networkFetcher: APIClientFetcher? = nil
    ) {
        super.init(environment: environment, fetcher: networkFetcher)
    }
    
    public func fetchNews() async throws -> [Post] {
        try await fetch(
            AtegalAPI.getPosts,
            as: [Post].self
        )
    }
}
