//
//  Created by Michele Restuccia on 28/8/25.
//

import Foundation

public enum APIClientError: LocalizedError, Equatable, Sendable {
    case server(message: String, statusCode: Int)
    case malformedURL
    case parameterEncodingFailed
    case badServerResponse
    case tokenFailed
    case failParseJSON

    public var errorDescription: String? {
        "error"
    }
}

public enum ParsingError: Swift.Error, Sendable {
    case malformedDate
    case missingCalendarRange
}
