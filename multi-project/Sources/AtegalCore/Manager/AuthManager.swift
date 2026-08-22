//
//  Created by Michele Restuccia on 16/08/26.
//

import Foundation
import Observation

#if os(Android)
import SkipFuse
#endif

#if os(iOS)
import AuthenticationServices
#endif

@Observable
public class AuthManager {

    @ObservationIgnored
    private let socialNetworkManager: SocialNetworkManager
    public private(set) var isAuthenticated: Bool

    public init() {
        self.socialNetworkManager = SocialNetworkManager()
        self.isAuthenticated = socialNetworkManager.isAuthenticated()
    }
    
    #if os(iOS)
    @MainActor
    public func configureAppleSignIn(_ request: ASAuthorizationAppleIDRequest) {
        socialNetworkManager.configureAppleSignIn(request)
    }
    #endif

    @MainActor
    public func signIn(with network: SocialNetwork) async throws {
        try await socialNetworkManager.signIn(network: network)
        updateAuthenticationState(true)
    }
    
    public func signOut() throws {
        try socialNetworkManager.signOut()
        updateAuthenticationState(false)
    }
    
    public func fetchUser() -> User? {
        socialNetworkManager.currentUser()
    }
    
    func updateAuthenticationState(_ isAuthenticated: Bool) {
        self.isAuthenticated = isAuthenticated
    }
}

// MARK: - Mocks

public final class MockAuthManager: AuthManager {

    public private(set) var signedInNetwork: SocialNetwork?
    public private(set) var didSignOut = false
    public var user: User?
    public override init() {
        super.init()
    }

    @MainActor
    public override func signIn(with network: SocialNetwork) async throws {
        signedInNetwork = network
        updateAuthenticationState(true)
    }

    public override func signOut() throws {
        didSignOut = true
        updateAuthenticationState(false)
    }

    public override func fetchUser() -> User? {
        user
    }
}
