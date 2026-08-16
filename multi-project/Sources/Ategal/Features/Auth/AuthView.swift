//
//  Created by Michele Restuccia on 16/08/26.
//

import SwiftUI
import AtegalCore
import RStudioKit

#if canImport(Darwin)

// MARK: - Previews

@available(iOS 18, *)
#Preview {
    
    NavigationStack {
        AuthView(
            authManager: MockAuthManager(),
            onAuthenticated: {}
        )
        .dynamicTypeSize(.large ... .accessibility5)
    }
}
#endif

// MARK: - AuthView

struct AuthView: View {

    let authManager: AuthManager
    let onAuthenticated: () -> Void

    @State
    var errorMessage: String?

    var body: some View {
        contentView
            .actionView{ actionView }
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
            .interactiveDismissDisabled()
            .presentationDetents([.medium])
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
        .background(ColorsPalette.background)
    }
    
    @ViewBuilder
    private var actionView: some View {
        VStack(spacing: 8) {
            AsyncButton {
                await authenticate(with: .google)
            } label: {
                HStack(spacing: 12) {
                    Text("G")
                        .font(.title3.bold())
                        .foregroundStyle(ColorsPalette.textTertiary)
                        .frame(width: 24, height: 24)

                    Text("auth-google-action")
                        .font(.headline)
                        .foregroundStyle(ColorsPalette.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .cornerBackground(ColorsPalette.primary, radius: 14)
            }
        }
    }
    
    // MARK: - Actions
    
    private func authenticate(with network: SocialNetwork) async {
        do {
            try await authManager.signIn(with: network)
            guard authManager.isAuthenticated() else { return }
            onAuthenticated()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
