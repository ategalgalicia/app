//
//  Created by Michele Restuccia on 02/10/2026.
//

import SwiftUI

struct AtegalTabView: View {
    
    @Binding
    var selection: ContentTab
    
    @Binding
    var navigationHome: [HomeRoute]
    
    @Binding
    var navigationPost: [PostRoute]
    
    let world: World
    
    var body: some View {
        TabView(selection: Binding(
            get: { selection },
            set: { tab in
                #if os(Android)
                if tab == selection {
                    switch tab {
                    case .home: navigationHome.removeAll()
                    case .posts: navigationPost.removeAll()
                    case .whoWeAre, .profile:
                        break
                    }
                }
                #endif
                selection = tab
            }
        )) {
            HomeAsyncView(
                navigationPath: $navigationHome,
                wpApiClient: world.wpApiClient,
                gistApiClient: world.gistApiClient,
                appVersion: world.appVersion
            )
            .tabItem { label(for: .home) }
            .tag(ContentTab.home)
            
            WhoWeAreAsyncView(
                apiClient: world.gistApiClient
            )
            .tabItem { label(for: .whoWeAre) }
            .tag(ContentTab.whoWeAre)
            
            PostListAsyncView(
                navigationPath: $navigationPost,
                apiClient: world.wpApiClient
            )
            .tabItem { label(for: .posts) }
            .tag(ContentTab.posts)
            
            ProfileView(
                authManager: world.authManager,
                pushManager: world.pushManager
            )
            .tabItem { label(for: .profile) }
            .tag(ContentTab.profile)
        }
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private func label(for tab: ContentTab) -> some View {
        Label(tab.title, systemImage: tab.icon)
    }
}
