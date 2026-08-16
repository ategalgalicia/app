//
//  Created by Michele Restuccia on 16/08/26.
//

import Foundation
import SkipFirebaseAuth
import SkipFirebaseCore

#if canImport(GoogleSignIn)
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

public enum SocialNetwork: Sendable, Equatable {
    case apple
    case google
}

// MARK: - SocialNetworkManager

class SocialNetworkManager {

    private let auth: Auth

    init() {
        self.auth = Auth.auth()
    }

    func isAuthenticated() -> Bool {
        auth.currentUser != nil
    }

    @MainActor
    func signIn(network: SocialNetwork) async throws {
        switch network {
        case .apple:
            fatalError()
        case .google:
            try await signInWithGoogle()
        }
    }
}

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
            guard nsError.domain == "com.google.GIDSignIn", nsError.code == -5 else {
                throw error
            }
            throw CancellationError()
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
