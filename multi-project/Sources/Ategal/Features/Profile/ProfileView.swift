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
        ProfileView(
            authManager: MockAuthManager(),
            pushManager: PushManager()
        )
        .dynamicTypeSize(.large ... .accessibility5)
    }
}
#endif

// MARK: - AuthView

struct ProfileView: View {
    
    let authManager: AuthManager
    let pushManager: PushManager

    @State
    var presentAuthSheet: Bool = false

    @State
    var presentTutorial: Bool = false
    
    var body: some View {
        contentView
            .tint(ColorsPalette.primary)
            .navigationTitle("tab-profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $presentAuthSheet) {
                PlatformModalSheet(title: "auth-title".localized) {
                    AuthView(authManager: authManager)
                }
            }
            .fullScreenCover(isPresented: $presentTutorial) {
                TutorialView(isPresented: $presentTutorial)
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
                userView
                pushNotificationsView
                if !authManager.isLogged {
                    tutorialButton
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(ColorsPalette.background)
            .animation(.default, value: authManager.userStatus)
        }
    }
    
    @ViewBuilder
    private var signInView: some View {
        if !authManager.isLogged {
            VStack(spacing: 16) {
                Text("profile-sign-in-subtitle")
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
    
    @ViewBuilder
    private var userView: some View {
        if authManager.isLogged, let user = authManager.fetchUser() {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    if let firstName = user.firstName {
                        Text(firstName)
                    }
                    if let lastName = user.lastName {
                        Text(lastName)
                    }
                }
                .font(.title2.bold())
                .foregroundStyle(ColorsPalette.textPrimary)

                if let email = user.email {
                    Label(email, systemImage: "envelope")
                        .font(.subheadline)
                        .foregroundStyle(ColorsPalette.textSecondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private var pushNotificationsView: some View {
        if authManager.isLogged, pushManager.isPushAuthorized {
            AsyncView(id: pushManager.isPushAuthorized) {
                await pushManager.hasPushAuthorization()
            } content: { hasPushAuthorization in
                if hasPushAuthorization {
                    PushTopicView(pushManager: pushManager)
                } else {
                    Text("notification-permission-subtitle")
                }
            }
            .padding(.vertical, 16)
        }
    }

    @ViewBuilder
    private var tutorialButton: some View {
        Button {
            presentTutorial = true
        } label: {
            Label("push-tutorial-profile-action", systemImage: "info.circle")
                .font(.headline)
                .foregroundStyle(ColorsPalette.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .cornerBackground(ColorsPalette.cardBackground, radius: 14)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func toolbarIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.title3)
            #if os(Android)
            .padding(12)
            .background(ColorsPalette.cardBackground)
            .clipShape(Circle())
            #endif
    }
    
    // MARK: - ToolbarContentBuilder
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if authManager.isLogged {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    presentTutorial = true
                } label: {
                    toolbarIcon("info.circle")
                }
                .accessibilityLabel(Text("push-tutorial-profile-action"))

                AsyncButton {
                    try authManager.signOut()
                } label: {
                    toolbarIcon("arrow.forward.square")
                }
                .accessibilityLabel(Text("auth-logout-action"))
            }
        }
    }
}

// MARK: - Extensions

private extension AuthManager {

    var isLogged: Bool {
        userStatus == .logged
    }
}
