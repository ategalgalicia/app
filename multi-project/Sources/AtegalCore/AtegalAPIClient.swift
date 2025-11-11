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
    
    public func fetchCenters() -> [Center] {
        [
            readFromBundle("santiago"),
            readFromBundle("coruna"),
            readFromBundle("ferrol"),
            readFromBundle("ourense"),
            readFromBundle("padron"),
            readFromBundle("lalin"),
            readFromBundle("vigo")
        ]
    }
    
    public func fetchPosts() async throws -> [Post] {
        try await fetch(
            AtegalAPI.getPosts,
            as: [Post].self
        )
    }
}

private extension AtegalAPIClient {
    
    func readFromBundle(_ center: String) -> AtegalCore.Center {
        let url = Bundle.module.url(forResource: center, withExtension: "json")
        guard let url,
              let json = try? Data(contentsOf: url, options: .mappedIfSafe),
              let preferences = try? JSONDecoder().decode(Center.self, from: json)
        else {
            fatalError()
        }
        return preferences
    }
}
