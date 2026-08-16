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
        ProfileView(authManager: MockAuthManager())
        .dynamicTypeSize(.large ... .accessibility5)
    }
}
#endif

// MARK: - AuthView

struct ProfileView: View {
    
    let authManager: AuthManager

    @State
    var presentAuthSheet: Bool = false
    
    var body: some View {
        contentView
            .tint(ColorsPalette.primary)
            .navigationTitle("tab-profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $presentAuthSheet) {
                PlatformModalSheet(title: "auth-title".localized) {
                    AuthView(
                        authManager: authManager,
                        onAuthenticated: { presentAuthSheet = false }
                    )
                }
            }
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(ColorsPalette.primary)
                    .accessibilityHidden(true)
                
                signInView
            }
            .padding(16)
        }
        .background(ColorsPalette.background)
    }
    
    @ViewBuilder
    private var signInView: some View {
        if !authManager.isAuthenticated() {
            VStack(spacing: 16) {
                Text("auth-subtitle")
                    .font(.body)
                    .foregroundStyle(ColorsPalette.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    presentAuthSheet = true
                } label: {
                    Text("auth-login-action")
                        .font(.headline)
                        .foregroundStyle(ColorsPalette.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .cornerBackground(ColorsPalette.primary, radius: 14)
                }
            }
        }
    }
}
