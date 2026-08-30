//
//  Created by Michele Restuccia on 28/10/25.
//

import SwiftUI
import RStudioKit
import AtegalCore

enum ContentTab: String, Hashable {
    case home, whoWeAre, posts, profile
}

struct ContentView: View {
    
    @State
    var tab = ContentTab.home
    
    @State
    var navigationHome: [HomeRoute] = []
    
    @State
    var navigationPost: [PostRoute] = []
    
    let world: World

    @ViewBuilder
    var body: some View {
        TabView(selection: $tab) {
            homeFlow
            whoWeAreFlow
            postsFlow
            profileFlow
        }
        .preferredColorScheme(.light)
        .tint(ColorsPalette.primary)
        .background(ColorsPalette.background)
        .ategalTabBarConfiguration()
        .applyAccessibility()
        // Keeps the FCM topic subscription aligned with the session state.
        .task(id: world.authManager.userStatus) {
            await world.pushManager.refreshUserStatus(
                world.authManager.userStatus
            )
        }
        .onChange(of: world.currentDeeplink, initial: true) { _, payload in
            guard let payload else {
                return
            }
            tab = .home
            navigationHome = [.deeplink(payload)]
            world.currentDeeplink = nil
        }
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var homeFlow: some View {
        NavigationStack(path: $navigationHome) {
            HomeAsyncView(
                navigationPath: $navigationHome,
                wpApiClient: world.wpApiClient,
                gistApiClient: world.gistApiClient,
                appVersion: world.appVersion
            )
        }
        .tabItem { Label("tab-home", systemImage: "house.fill") }
        .tag(ContentTab.home)
    }
    
    @ViewBuilder
    private var whoWeAreFlow: some View {
        NavigationStack {
            WhoWeAreAsyncView(apiClient: world.gistApiClient)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tabItem { Label("tab-who-we-are", systemImage: "person.crop.circle") }
        .tag(ContentTab.whoWeAre)
        
    }
    
    @ViewBuilder
    private var postsFlow: some View {
        NavigationStack(path: $navigationPost) {
            PostListAsyncView(
                navigationPath: $navigationPost,
                apiClient: world.wpApiClient
            )
        }
        .tabItem { Label("tab-posts", systemImage: "pencil") }
        .tag(ContentTab.posts)
    }
    
    @ViewBuilder
    private var profileFlow: some View {
        NavigationStack {
            ProfileView(
                authManager: world.authManager,
                pushManager: world.pushManager
            )
        }
        .tabItem { Label("tab-profile", systemImage: "person.fill") }
        .tag(ContentTab.profile)
    }
}
