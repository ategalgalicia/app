//
//  Created by Michele Restuccia on 27/10/25.
//

import Foundation

#if os(Android)
import FoundationNetworking
#endif

// MARK: APIClientResponse

public struct APIClientResponse: Sendable {
    let data: Data
    let httpResponse: HTTPURLResponse
}

// MARK: APIClientFetcher

public protocol APIClientFetcher {
    func fetchData(with request: URLRequest) async throws -> APIClientResponse
}

// MARK: URLSessionFetcher

final class URLSessionFetcher: APIClientFetcher, @unchecked Sendable {
    private let session: URLSession

    init(session: URLSession = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)) {
        self.session = session
    }

    func fetchData(with request: URLRequest) async throws -> APIClientResponse {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIClientError.badServerResponse }
        return .init(data: data, httpResponse: http)
    }
}

// MARK: MockNetworkFetcher

actor MockNetworkFetcher: APIClientFetcher {
    private var mockedData: Data?
    private var mockedStatusCode: Int = 200
    private var lastRequestHeaders: HTTPHeaders?
    
    func setMockedData(_ data: Data) async {
        self.mockedData = data
    }
    func setMockedStatusCode(_ code: Int) {
        mockedStatusCode = code
    }
    func getLastRequestHeaders() async throws -> HTTPHeaders? {
        lastRequestHeaders
    }
    func fetchData(with request: URLRequest) async throws -> APIClientResponse {
        lastRequestHeaders = request.allHTTPHeaderFields
        guard let data = mockedData else {
            throw URLError(.badURL)
        }
        guard let url = request.url else {
            throw URLError(.badURL)
        }
        guard let response = HTTPURLResponse(url: url, statusCode: mockedStatusCode, httpVersion: nil, headerFields: nil) else {
            throw URLError(.badServerResponse)
        }
        return .init(data: data, httpResponse: response)
    }
}
