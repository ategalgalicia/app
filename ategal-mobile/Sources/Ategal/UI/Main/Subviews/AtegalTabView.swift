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
        TabView(
            selection: Binding(
                get: { selection },
                set: { selection = $0 }
            ),
            content: { tabs }
        )
        .tint(ColorsPalette.primary)
    }
    
    // MARK: - ViewBuilders
    
    @TabContentBuilder<ContentTab>
    private var tabs: some TabContent<ContentTab> {
        Tab(value: ContentTab.home) {
            HomeAsyncView(
                navigationPath: $navigationHome,
                wpApiClient: world.wpApiClient,
                gistApiClient: world.gistApiClient,
                appVersion: world.appVersion
            )
        } label: {
            label(for: .home)
        }
        
        Tab(value: ContentTab.whoWeAre) {
            WhoWeAreAsyncView(
                apiClient: world.gistApiClient
            )
        } label: {
            label(for: .whoWeAre)
        }
        
        Tab(value: ContentTab.posts) {
            PostListAsyncView(
                navigationPath: $navigationPost,
                apiClient: world.wpApiClient
            )
        } label: {
            label(for: .posts)
        }
        
        Tab(value: ContentTab.inbox) {
            InboxAsyncView(
                navigationPath: $navigationInbox,
                announcementManager: world.announcementManager,
                gistApiClient: world.gistApiClient,
                wpApiClient: world.wpApiClient
            )
        } label: {
            label(for: .inbox)
        }
        .ategalBadge(world.announcementManager.unreadCount)
        .hidden(world.authManager.userStatus != .logged)
        
        Tab(value: ContentTab.profile) {
            ProfileView(
                authManager: world.authManager,
                pushManager: world.pushManager,
                announcementManager: world.announcementManager,
                gistApiClient: world.gistApiClient
            )
        } label: {
            label(for: .profile)
        }
    }
    
    @ViewBuilder
    private func label(for tab: ContentTab) -> some View {
        Label(tab.title, systemImage: tab.icon)
            .foregroundStyle(ColorsPalette.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension TabContent {
    nonisolated func ategalBadge(_ count: Int) -> some TabContent<Self.TabValue> {
        #if canImport(Darwin)
        return badge(count)
        #else
        var content = self
        content.modifiers.append { $0.badge(count) }
        return content
        #endif
    }
}
