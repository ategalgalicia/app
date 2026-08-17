//
//  Created by Michele Restuccia on 16/08/26.
//

import Foundation
import SkipFirebaseAuth
import SkipFirebaseCore

#if os(iOS)
import AuthenticationServices
import CryptoKit
import GoogleSignIn
import UIKit
#endif

#if SKIP
import SkipUI
import androidx.credentials.CredentialManager
import androidx.credentials.CustomCredential
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialCancellationException
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.google.firebase.auth.GoogleAuthProvider
#endif

// MARK: - SocialNetwork

public enum SocialNetwork: Equatable {
    #if os(iOS)
    case apple(ASAuthorization)
    #endif
    case google
}

// MARK: - SocialNetworkManager

class SocialNetworkManager {

    private let auth: Auth
    #if os(iOS)
    private var appleNonce: String?
    #endif

    init() {
        self.auth = Auth.auth()
    }

    func isAuthenticated() -> Bool {
        currentUser() != nil
    }
    
    func currentUser() -> User? {
        guard let currentUser = auth.currentUser else {
            return nil
        }
        let nameComponents = currentUser.displayName?
            .split(separator: " ", maxSplits: 1)
            .map(String.init)
        return User(
            firstName: nameComponents?.first,
            lastName: nameComponents?.dropFirst().first,
            email: currentUser.email
        )
    }

    @MainActor
    func signIn(network: SocialNetwork) async throws {
        switch network {
        #if os(iOS)
        case .apple(let authorization):
            guard let appleNonce else {
                throw AppleAuthenticationError.missingNonce
            }
            self.appleNonce = nil
            try await signIn(
                with: authorization,
                rawNonce: appleNonce
            )
        #endif
        case .google:
            try await signInWithGoogle()
        }
    }
    
    func signOut() throws {
        try auth.signOut()
    }
}

// MARK: - Apple

#if os(iOS)
extension SocialNetworkManager {

    @MainActor
    func configureAppleSignIn(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = UUID().uuidString
        appleNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = SHA256.hash(data: Data(nonce.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    @MainActor
    func signIn(
        with authorization: ASAuthorization,
        rawNonce: String
    ) async throws {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityToken = credential.identityToken,
            let idToken = String(data: identityToken, encoding: .utf8)
        else {
            throw AppleAuthenticationError.invalidCredential
        }

        let firebaseCredential = OAuthProvider.credential(
            providerID: .apple,
            idToken: idToken,
            rawNonce: rawNonce
        )
        _ = try await auth.signIn(with: firebaseCredential)
    }
}
#endif

// MARK: - Google

private extension SocialNetworkManager {

    @MainActor
    func signInWithGoogle() async throws {
        #if os(Android)
        try await signInWithGoogleOnAndroid()
        #else
        try await signInWithGoogleOnApplePlatform()
        #endif
    }

    #if canImport(GoogleSignIn)
    @MainActor
    func signInWithGoogleOnApplePlatform() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw GoogleAuthenticationError.clientIDNotFound
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let presenter = scene.windows.first(where: \.isKeyWindow)?.rootViewController
        else {
            throw GoogleAuthenticationError.presentingWindowNotFound
        }
        let result: GIDSignInResult
        do {
            result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
        } catch {
            let nsError = error as NSError
            if nsError.domain == "com.google.GIDSignIn", nsError.code == -5 {
                return
            }
            throw error
        }

        guard let idToken = result.user.idToken?.tokenString else {
            throw GoogleAuthenticationError.idTokenNotFound
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        _ = try await auth.signIn(with: credential)
    }
    #endif

}

#if SKIP
// SKIP @bridge
@MainActor
func signInWithGoogleOnAndroid() async throws {
    guard let activity: androidx.appcompat.app.AppCompatActivity = UIApplication.shared.androidActivity else {
        throw GoogleAuthenticationError.presentingWindowNotFound
    }

    let resourceID = activity.resources.getIdentifier(
        "default_web_client_id",
        "string",
        activity.packageName
    )
    guard resourceID != 0 else {
        throw GoogleAuthenticationError.clientIDNotFound
    }

    let googleIDOption = GetGoogleIdOption.Builder()
        .setFilterByAuthorizedAccounts(false)
        .setServerClientId(activity.getString(resourceID))
        .build()
    let request = GetCredentialRequest.Builder()
        .addCredentialOption(googleIDOption)
        .build()
    let manager: CredentialManager = CredentialManager.create(activity)
    let result: androidx.credentials.GetCredentialResponse
    do {
        // SKIP NOWARN
        result = try await manager.getCredential(activity, request)
    } catch is GetCredentialCancellationException {
        return
    } catch {
        throw error
    }

    guard
        let credential = result.credential as? CustomCredential,
        credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL
    else {
        throw GoogleAuthenticationError.unexpectedCredential
    }

    let googleCredential = GoogleIdTokenCredential.createFrom(credential.data)
    let firebaseCredential = GoogleAuthProvider.getCredential(
        googleCredential.idToken,
        nil
    )
    let auth = Auth.auth()
    _ = try await auth.signIn(with: AuthCredential(firebaseCredential))
}
#endif

// MARK: - Errors

enum AppleAuthenticationError: LocalizedError {
    case invalidCredential
    case missingNonce

    var errorDescription: String? {
        switch self {
        case .invalidCredential: "auth-apple-error-credential"
        case .missingNonce: "auth-apple-error-nonce"
        }
    }
}
 
// SKIP @bridge
enum GoogleAuthenticationError: LocalizedError {
    case clientIDNotFound
    case presentingWindowNotFound
    case idTokenNotFound
    case unexpectedCredential
    case unsupportedPlatform

    var errorDescription: String? {
        switch self {
        case .clientIDNotFound: "auth-google-error-client-id"
        case .presentingWindowNotFound: "auth-google-error-presenter"
        case .idTokenNotFound, .unexpectedCredential: "auth-google-error-credential"
        case .unsupportedPlatform: "auth-google-error-unavailable"
        }
    }
}
