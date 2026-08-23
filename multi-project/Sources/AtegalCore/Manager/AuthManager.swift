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

public enum UserStatus {
    case logged, unlogged
}

@MainActor
@Observable
public class AuthManager {

    @ObservationIgnored
    private let socialNetworkManager: SocialNetworkManager
    
    public private(set) var userStatus: UserStatus

    public init() {
        self.socialNetworkManager = SocialNetworkManager()
        self.userStatus = socialNetworkManager.isAuthenticated() ? .logged : .unlogged
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
        updateAuthenticationState(.logged)
    }
    
    public func signOut() throws {
        try socialNetworkManager.signOut()
        updateAuthenticationState(.unlogged)
    }
    
    public func fetchUser() -> User? {
        socialNetworkManager.currentUser()
    }
    
    func updateAuthenticationState(_ status: UserStatus) {
        self.userStatus = status
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
        updateAuthenticationState(.logged)
    }

    public override func signOut() throws {
        didSignOut = true
        updateAuthenticationState(.unlogged)
    }

    public override func fetchUser() -> User? {
        user
    }
}
