//
//  Created by Michele Restuccia on 24/12/25.
//

import Foundation

public class GistAPIClient: APIClient, @unchecked Sendable {
    
    public init(
        environment: GistEnvironment = .init(),
        networkFetcher: APIClientFetcher? = nil
    ) {
        super.init(environment: environment, fetcher: networkFetcher)
    }
    
    public func fetchCenters() async -> [Center] {
        do {
            return try await fetch(
                GistEndpoint.getCenters, as: [Center].self
            )
        } catch {
            return readCentersFromBundle()
        }
    }
}

private extension GistAPIClient {
    
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

public struct GistEnvironment: Environment, Sendable {
    public init() {}
    public var baseURL: URL {
        URL(string: "https://gist.githubusercontent.com/ategalgalicia/")!
    }
}
