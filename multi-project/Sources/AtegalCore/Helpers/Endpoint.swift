//
//  Created by Michele Restuccia on 25/7/25.
//

import Foundation

public protocol Endpoint: Sendable {
    var path: String { get }
    var method: HTTPMethod { get }
    var httpHeaders: HTTPHeaders { get }
    var parameterEncoding: HTTPParameterEncoding { get }
    var parameters: HTTPParameters? { get }
}

extension Endpoint {
    public var method: HTTPMethod { .GET }
    public var httpHeaders: HTTPHeaders { [:] }
    public var parameterEncoding: HTTPParameterEncoding { .url }
    public var parameters: [String: Any]? { nil }
}

public enum HTTPMethod: String, Sendable {
    case GET, POST, PUT, DELETE, OPTIONS, HEAD, PATCH, TRACE, CONNECT
}
public enum HTTPParameterEncoding: Sendable {
    case url, json
}
public typealias HTTPParameters = [String: Any]
public typealias HTTPHeaders = [String: String]
