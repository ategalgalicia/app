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
        readCentersFromBundle()
    }
    
    public func fetchPosts() async throws -> [Post] {
        do {
            return try await fetch(
                AtegalAPI.getPosts, as: [Post].self
            )
        } catch {
            return []
        }
    }
    
    public func fetchCalendarEvents() async -> [Event] {
        do {
            let data = try await fetch(
                AtegalAPI.getCalendarEvents, as: Data.self
            )
            guard let ics = String(data: data, encoding: .utf8) else {
                throw URLError(.cannotDecodeContentData)
            }
            return ics.parseAsCalendar()
        } catch {
            return []
        }
    }
}

private extension AtegalAPIClient {
    
    func readCentersFromBundle() -> [AtegalCore.Center] {
        let url = Bundle.module.url(forResource: "ategal", withExtension: "json")
        guard let url,
              let json = try? Data(contentsOf: url, options: .mappedIfSafe),
              let items = try? JSONDecoder().decode([Center].self, from: json)
        else {
            fatalError()
        }
        return items
    }
}
