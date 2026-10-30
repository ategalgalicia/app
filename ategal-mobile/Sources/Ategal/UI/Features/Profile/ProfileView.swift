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
            pushManager: PushManager(),
            announcementManager: AnnouncementManager(),
            gistApiClient: GistAPIClient()
        )
    }
}
#endif

// MARK: - AuthView

struct ProfileView: View {
    
    let authManager: AuthManager
    let pushManager: PushManager
    let announcementManager: AnnouncementManager
    let gistApiClient: GistAPIClient
    
    @State
    var sheetType: SheetType?
    enum SheetType: Identifiable, Equatable {
        case auth
        case tutorial
        var id: Int { self.hashValue }
    }

    @State
    var presentLogoutConfirmation: Bool = false

    @State
    var logoutError: Error?
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("tab-profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .sheet(item: $sheetType) { sheet($0) }
                .errorAlert($logoutError)
                .alert("auth-logout-action", isPresented: $presentLogoutConfirmation) {
                    Button("cancel", role: .cancel) {}
                    Button("auth-logout-action", role: .destructive) {
                        do {
                            try authManager.signOut()
                        } catch {
                            logoutError = error
                        }
                    }
                } message: {
                    Text("auth-logout-confirmation-message")
                }
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 72))
                    .foregroundStyle(ColorsPalette.primary)
                    .accessibilityHidden(true)
                
                if authManager.isLogged {
                    userView
                    pushNotificationsView
                } else {
                    Text("profile-sign-in-subtitle")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(ColorsPalette.textSecondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 32)
                    
                    VStack(spacing: 8) {
                        signinButton
                        tutorialButton
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .animation(.default, value: authManager.userStatus)
        }
        .background(ColorsPalette.background)
    }
    
    @ViewBuilder
    private var userView: some View {
        if let user = authManager.fetchUser() {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    if let firstName = user.firstName {
                        Text(firstName)
                    }
                    if let lastName = user.lastName {
                        Text(lastName)
                    }
                }
                .font(.title2.weight(.semibold))
                .foregroundStyle(ColorsPalette.textPrimary)
                .accessibilityHeading(.h1)

                if let email = user.email {
                    Label(email, systemImage: "envelope")
                        .font(.subheadline)
                        .foregroundStyle(ColorsPalette.textSecondary)
                }
            }
            .padding(.bottom, 16)
        }
    }
    
    @ViewBuilder
    private var pushNotificationsView: some View {
        if pushManager.isPushAuthorized {
            AsyncView(id: pushManager.isPushAuthorized) {
                await pushManager.hasPushAuthorization()
            } content: { hasPushAuthorization in
                if hasPushAuthorization {
                    PushTopicView(
                        pushManager: pushManager,
                        announcementManager: announcementManager
                    )
                } else {
                    Text("notification-permission-subtitle")
                        .font(.body)
                        .foregroundStyle(ColorsPalette.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    private var signinButton: some View {
        Button {
            sheetType = .auth
        } label: {
            Text("auth-login-action")
                .font(.body.weight(.medium))
                .foregroundStyle(ColorsPalette.textTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .ategalCornerPrimaryBackground()
    }

    @ViewBuilder
    private var tutorialButton: some View {
        Button {
            sheetType = .tutorial
        } label: {
            Label("push-tutorial-navigation-title", systemImage: "info.circle")
                .font(.body.weight(.medium))
                .foregroundStyle(ColorsPalette.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
        .ategalCornerBackground()
    }
    
    @ViewBuilder
    private func sheet(_ type: SheetType) -> some View {
        switch type {
        case .auth:
            AuthView(authManager: authManager)
        case .tutorial:
            TutorialView(isPresented: Binding(
                get: { sheetType == .tutorial },
                set: { isPresented in
                    if !isPresented, sheetType == .tutorial {
                        sheetType = nil
                    }
                }
            ))
            #if canImport(Darwin)
            .presentationCompactAdaptation(.fullScreenCover)
            #endif
        }
    }
    
    // MARK: - ToolbarContentBuilder
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if authManager.isLogged {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    sheetType = .tutorial
                } label: {
                    toolbarIcon("info.circle")
                }
                .clipShape(Circle())
                .accessibilityLabel(Text("push-tutorial-navigation-title"))

                Button {
                    presentLogoutConfirmation = true
                } label: {
                    toolbarIcon("arrow.forward.square")
                }
                .clipShape(Circle())
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
