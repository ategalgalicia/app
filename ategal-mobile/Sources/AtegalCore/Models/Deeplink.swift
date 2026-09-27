import Foundation

// MARK: - DeeplinkHandler

public typealias DeeplinkHandler = (DeeplinkPayload) -> Void

// MARK: - DeeplinkPayload

public struct DeeplinkPayload: Hashable, Sendable {
    public let activity: String
    public let query: String?

    public init(activity: String, query: String?) {
        self.activity = activity
        self.query = query?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Deeplink

public struct Deeplink: Hashable, Sendable {
    public let action: Action

    public enum Action: Hashable, Sendable {
        case search(query: String)
    }

    public enum ResolutionError: Error, Equatable, Sendable {
        case unsupportedActivity
        case missingQuery
    }

    public static func resolve(payload: DeeplinkPayload) async throws -> Deeplink {
        switch payload.activity {
        case Path.search:
            guard let query = payload.query, !query.isEmpty else {
                throw ResolutionError.missingQuery
            }
            return Deeplink(action: .search(query: query))
        default:
            throw ResolutionError.unsupportedActivity
        }
    }
}

// MARK: - Path

private enum Path {
    static let search = "search"
}
