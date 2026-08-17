import XCTest
@testable import AtegalCore

@MainActor
final class AuthManagerTests: XCTestCase {

    func testSignInDelegatesSelectedNetwork() async throws {
        let socialNetworkManager = SocialNetworkManagerSpy()
        let manager = AuthManager(socialNetworkManager: socialNetworkManager)

        try await manager.signIn(with: .google)

        guard case .google = socialNetworkManager.receivedNetwork else {
            return XCTFail("Expected Google sign in")
        }
        XCTAssertTrue(manager.isAuthenticated)
    }

    func testSignInPropagatesProviderError() async {
        let socialNetworkManager = SocialNetworkManagerSpy(
            signInError: TestError.expected
        )
        let manager = AuthManager(socialNetworkManager: socialNetworkManager)

        do {
            try await manager.signIn(with: .google)
            XCTFail("Expected the provider error")
        } catch {
            XCTAssertTrue(error is TestError)
        }
    }

    func testSignOutDelegatesToSocialNetworkManager() throws {
        let socialNetworkManager = SocialNetworkManagerSpy()
        let manager = AuthManager(socialNetworkManager: socialNetworkManager)

        try manager.signOut()

        XCTAssertTrue(socialNetworkManager.didSignOut)
        XCTAssertFalse(manager.isAuthenticated)
    }
}

private enum TestError: Error {
    case expected
}

private final class SocialNetworkManagerSpy: SocialNetworkManager {

    var receivedNetwork: SocialNetwork?
    var signInError: Error?
    var didSignOut = false

    init(signInError: Error? = nil) {
        self.signInError = signInError
        super.init()
    }

    override func isAuthenticated() -> Bool {
        false
    }

    override func signOut() throws {
        didSignOut = true
    }

    @MainActor
    override func signIn(network: SocialNetwork) async throws {
        receivedNetwork = network
        if let signInError {
            throw signInError
        }
    }
}
