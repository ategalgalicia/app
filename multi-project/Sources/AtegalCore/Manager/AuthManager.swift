//
//  Created by Michele Restuccia on 16/08/26.
//

import Foundation

public class AuthManager {

    private let socialNetworkManager: SocialNetworkManager

    public init() {
        self.socialNetworkManager = SocialNetworkManager()
    }

    init(socialNetworkManager: SocialNetworkManager) {
        self.socialNetworkManager = socialNetworkManager
    }

    @MainActor
    public func signIn(with network: SocialNetwork) async throws {
        try await socialNetworkManager.signIn(network: network)
    }

    public func signOut() {
        fatalError()
    }

    public func isAuthenticated() -> Bool {
        socialNetworkManager.isAuthenticated()
    }

    public func fetchPersonalData() {
        fatalError()
    }
}

// MARK: - Mocks

public final class MockAuthManager: AuthManager {

    public private(set) var signedInNetwork: SocialNetwork?
    public private(set) var didSignOut = false
    public private(set) var didFetchPersonalData = false
    public var isAuthenticatedValue = false

    public override init() {
        super.init()
    }

    @MainActor
    public override func signIn(with network: SocialNetwork) async throws {
        signedInNetwork = network
        isAuthenticatedValue = true
    }

    public override func signOut() {
        didSignOut = true
        isAuthenticatedValue = false
    }

    public override func isAuthenticated() -> Bool {
        isAuthenticatedValue
    }

    public override func fetchPersonalData() {
        didFetchPersonalData = true
    }
}
