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

    @Binding
    var navigationInbox: [InboxRoute]
    
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
                    case .whoWeAre, .profile, .inbox:
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
            
            if world.authManager.userStatus == .logged {
                InboxAsyncView(
                    navigationPath: $navigationInbox,
                    announcementManager: world.announcementManager,
                    gistApiClient: world.gistApiClient,
                    wpApiClient: world.wpApiClient
                )
                .tabItem { label(for: .inbox) }
                .badge(world.announcementManager.unreadCount)
                .tag(ContentTab.inbox)
            }
            
            ProfileView(
                authManager: world.authManager,
                pushManager: world.pushManager,
                announcementManager: world.announcementManager,
                gistApiClient: world.gistApiClient
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
