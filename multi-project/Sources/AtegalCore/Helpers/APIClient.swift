//
//  Created by Michele Restuccia on 25/7/25.
//

import Foundation

#if os(Android)
import FoundationNetworking
#endif

public protocol APIClientDelegate: AnyObject {
    func didReceiveUnauthorized() async
}

public class APIClient {
    
    private let fetcher: APIClientFetcher
    private let environment: Environment
    
    open weak var delegate: APIClientDelegate?
    open var customizeRequest: @Sendable (URLRequest) -> (URLRequest) = { $0 }
    
    public init(
        environment: Environment,
        fetcher: APIClientFetcher? = nil
    ) {
        self.fetcher = fetcher ?? URLSessionFetcher()
        self.environment = environment
    }
    
    func fetch<T: Decodable>(_ endpoint: Endpoint, as type: T.Type = T.self) async throws -> T {
        do {
            let request = try createUrlRequest(endpoint)
            return try await perform(request, as: type)
        } catch APIClientError.tokenFailed {
            // Ask delegate to refresh credentials, then one last attempt
            await delegate?.didReceiveUnauthorized()
            
            // Optional small backoff to avoid thundering herds
            // try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
            
            let retryRequest = try createUrlRequest(endpoint)
            // If this throws, we propagate (max 2 attempts total)
            return try await perform(retryRequest, as: type)
        } catch {
            throw error
        }
    }
}

private extension APIClient {

    private func perform<T: Decodable>(_ urlRequest: URLRequest, as type: T.Type) async throws -> T {
        let response = try await fetcher.fetchData(with: urlRequest)
        let data = try await validateResponse(response)
        return try await makeDecoder(data: data, type: type)
    }

    private func createUrlRequest(_ endpoint: Endpoint) throws -> URLRequest {
        var urlRequest = try environment.createURLRequest(for: endpoint)
        urlRequest.httpMethod = endpoint.method.rawValue
        httpHeaders(for: endpoint, into: &urlRequest)

        switch endpoint.parameterEncoding {
        case .url:
            try encodeURLParameters(endpoint, into: &urlRequest)
        case .json:
            try encodeJSONParameters(endpoint, into: &urlRequest)
        }
        return customizeRequest(urlRequest)
    }
    
    private func validateResponse(_ response: APIClientResponse) async throws -> Data {
        guard (200..<300).contains(response.httpResponse.statusCode) else {
            if response.httpResponse.statusCode == 401 {
                throw APIClientError.tokenFailed
            } else {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys
                if let serverErr = try? decoder.decode(ServerErrorPayload.self, from: response.data) {
                    throw APIClientError.server(
                        message: serverErr.message,
                        statusCode: response.httpResponse.statusCode
                    )
                } else {
                    throw APIClientError.badServerResponse
                }
            }
        }
        return response.data
    }
    
    private func httpHeaders(for endpoint: Endpoint, into request: inout URLRequest) {
        for (key, value) in endpoint.httpHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    private func encodeURLParameters(_ endpoint: Endpoint, into request: inout URLRequest) throws {
        guard let parameters = endpoint.parameters, !parameters.isEmpty else { return }
        guard let requestURL = request.url,
              var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)
        else {
            throw APIClientError.parameterEncodingFailed
        }
        urlComponents.queryItems = try parameters.keys.sorted().map {
            guard let value = parameters[$0] else {
                throw APIClientError.parameterEncodingFailed
            }
            switch value {
            case let string as String:
                return URLQueryItem(name: $0, value: string)
            case let convertible as CustomStringConvertible:
                return URLQueryItem(name: $0, value: convertible.description)
            default:
                throw APIClientError.parameterEncodingFailed
            }
        }
        request.url = urlComponents.url
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    }
    
    private func encodeJSONParameters(_ endpoint: Endpoint, into request: inout URLRequest) throws {
        guard let parameters = endpoint.parameters, !parameters.isEmpty else { return }
        guard JSONSerialization.isValidJSONObject(parameters) else {
            throw APIClientError.parameterEncodingFailed
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: [.sortedKeys])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        } catch {
            throw APIClientError.parameterEncodingFailed
        }
    }
    
    private func makeDecoder<T: Decodable>(data: Data, type: T.Type) async throws -> T {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIClientError.failParseJSON
        }
    }
    
    private struct ServerErrorPayload: Decodable {
        let message: String
    }
}
