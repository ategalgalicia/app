//
//  Created by Michele Restuccia on 16/08/26.
//

import SwiftUI
import AtegalCore
import RStudioKit

#if os(iOS)
import AuthenticationServices
#endif

#if canImport(Darwin)

// MARK: - Previews

@available(iOS 18, *)
#Preview {
    
    NavigationStack {
        AuthView(authManager: MockAuthManager())
            .dynamicTypeSize(.large ... .accessibility5)
    }
}
#endif

// MARK: - AuthView

struct AuthView: View {

    let authManager: AuthManager

    @Environment(\.dismiss)
    var dismiss

    @State
    var errorMessage: String?

    @State
    var socialNetwork: SocialNetwork?
    
    var body: some View {
        contentView
            .actionView {
                VStack(spacing: 8) {
                    appleButton
                    googleButton
                }
            }
            .interactiveDismissDisabled()
            .presentationDetents([.medium])
            .performBlockingTask(
                value: $socialNetwork,
                successDisplaySeconds: 0,
                task: { await performAuthenticate($0) }
            )
            .alert(
                "auth-error-title",
                isPresented: .init(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("accept", role: .cancel) {}
            } message: {
                Text(LocalizedStringKey(errorMessage ?? ""))
            }
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image("logo-icon", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .accessibilityHidden(true)
                    .padding(.top, 16)

                Text("auth-subtitle")
                    .font(.body)
                    .foregroundStyle(ColorsPalette.textSecondary)
                    .multilineTextAlignment(.center)
                
                Text("auth-footer")
                    .font(.footnote)
                    .foregroundStyle(ColorsPalette.textSecondary)
                    .multilineTextAlignment(.center)
                
            }
            .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    private var appleButton: some View {
        #if os(iOS)
        SignInWithAppleButton(
            .continue,
            onRequest: authManager.configureAppleSignIn,
            onCompletion: {
                switch $0 {
                case .success(let authorization):
                    socialNetwork = .apple(authorization)
                case .failure(let error):
                    handleAuthenticationError(error)
                }
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        #endif
    }
    
    @ViewBuilder
    private var googleButton: some View {
        Button {
            socialNetwork = .google
        } label: {
            Label {
                Text("auth-google-action")
                    .font(.title3.bold())
            } icon: {
                Text(verbatim: "G")
                    .font(.headline.bold())
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(ColorsPalette.textTertiary)
            .padding(.vertical, 16)
            .cornerBackground(ColorsPalette.primary, radius: 14)
        }
    }
    
    // MARK: - Actions

    private func performAuthenticate(_ socialNetwork: SocialNetwork) async {
        do {
            try await authManager.signIn(with: socialNetwork)
            guard authManager.isAuthenticated else { return }
            dismiss()
        } catch {
            handleAuthenticationError(error)
        }
    }

    private func handleAuthenticationError(_ error: Error) {
        #if os(iOS)
        if let error = error as? ASAuthorizationError,
           error.shouldIgnoreAuthenticationError {
            return
        }
        #endif
        errorMessage = error.localizedDescription
    }
}

// MARK: - Extensions

#if os(iOS)
private extension ASAuthorizationError {

    var shouldIgnoreAuthenticationError: Bool {
        [1000, Self.Code.canceled.rawValue].contains(code.rawValue)
    }
}
#endif
