//
//  Created by Michele Restuccia on 27/10/25.
//

import Foundation

public class AtegalAPIClient: APIClient, @unchecked Sendable {
    
    public init(
        environment: AtegalEnvironment = .init(host: .production),
        networkFetcher: APIClientFetcher? = nil
    ) {
        super.init(environment: environment, fetcher: networkFetcher)
    }
    
    public func fetchCenters() -> [Center] {
        [
            readFromBundle("santiago"),
            readFromBundle("coruna"),
            readFromBundle("ferrol"),
            readFromBundle("lalin"),
            readFromBundle("monterroso"),
            readFromBundle("ourense"),
            readFromBundle("padron"),
            readFromBundle("vigo")
        ]
    }
    
    public func fetchPosts() async throws -> [Post] {
        try await fetch(
            AtegalAPI.getPosts,
            as: [Post].self
        )
    }
    
    public func fetchCalendarEvents() async throws -> [Event] {
        let data = try await fetch(
            AtegalAPI.getCalendarEvents,
            as: Data.self
        )
        guard let ics = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        return ics.parseAsCalendar()
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
