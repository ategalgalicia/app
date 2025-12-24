//
//  Created by Michele Restuccia on 27/10/25.
//

import Foundation

public class WPAPIClient: APIClient, @unchecked Sendable {
    
    public init(
        environment: WPEnvironment = .init(),
        networkFetcher: APIClientFetcher? = nil
    ) {
        super.init(environment: environment, fetcher: networkFetcher)
    }
    
    public func fetchPosts() async throws -> [Post] {
        do {
            return try await fetch(
                WPEndpoint.getPosts, as: [Post].self
            )
        } catch {
            return []
        }
    }
    
    public func fetchCalendarEvents() async -> [Event] {
        do {
            let data = try await fetch(
                WPEndpoint.getCalendarEvents, as: Data.self
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

public struct WPEnvironment: Environment, Sendable {
    public init() {}
    public var baseURL: URL {
        URL(string: "https://www.ategal.com/")!
    }
}
