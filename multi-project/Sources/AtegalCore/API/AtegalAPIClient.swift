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
    
    public func fetchCenters() async -> [Center] {
        struct CenterFetchError: Swift.Error {}
        do {
            let _data: Data? = try await {
                let urlString = "https://gist.githubusercontent.com/ategalgalicia/1090045bd5d98f9a692d4426b7f9f48e/raw/"
                guard let url = URL(string: urlString) else { return nil }
                let urlRequest = URLRequest(url: url, timeoutInterval: 3)
                let (data, _) = try await URLSession.shared.data(for: urlRequest)
                return data
            }()
            guard let data = _data else {
                throw CenterFetchError()
            }
            let results = try JSONDecoder().decode([Center].self, from: data)
            return results
        } catch {
            return readCentersFromBundle()
        }
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
