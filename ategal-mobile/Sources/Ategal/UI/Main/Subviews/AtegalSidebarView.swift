//
//  Created by Michele Restuccia on 02/10/2026.
//

#if canImport(Darwin)

import SwiftUI

struct AtegalSidebarView: View {
    
    @State
    var columnVisibility: NavigationSplitViewVisibility = .all
    
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
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            sidebar: { sidebarView },
            detail: { detailView.id(selection) }
        )
        .tint(ColorsPalette.primary)
        .navigationSplitViewStyle(.balanced)
        .toolbar(removing: .sidebarToggle)
    }

    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var sidebarView: some View {
        List(selection: Binding<ContentTab?>(
            get: { selection },
            set: { setSelection($0) }
        )) {
            label(.home)
            label(.whoWeAre)
            label(.posts)
            if world.authManager.userStatus == .logged {
                label(
                    .inbox,
                    badge: world.announcementManager.unreadCount
                )
            }
            label(.profile)
        }
        .listStyle(.sidebar)
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case .home:
            HomeAsyncView(
                navigationPath: $navigationHome,
                wpApiClient: world.wpApiClient,
                gistApiClient: world.gistApiClient,
                appVersion: world.appVersion
            )
            
        case .whoWeAre:
            WhoWeAreAsyncView(apiClient: world.gistApiClient)
            
            
        case .posts:
            PostListAsyncView(
                navigationPath: $navigationPost,
                apiClient: world.wpApiClient
            )

        case .inbox:
            if world.authManager.userStatus == .logged {
                InboxAsyncView(
                    navigationPath: $navigationInbox,
                    announcementManager: world.announcementManager,
                    gistApiClient: world.gistApiClient,
                    wpApiClient: world.wpApiClient
                )
            }

        case .profile:
            ProfileView(
                authManager: world.authManager,
                pushManager: world.pushManager,
                announcementManager: world.announcementManager,
                gistApiClient: world.gistApiClient
            )
        }
    }
    
    @ViewBuilder
    private func label(
        _ section: ContentTab,
        badge: Int? = nil
    ) -> some View {
        Label {
            HStack(spacing: 8) {
                Text(section.title)

                if let badge, badge > 0 {
                    Text("\(badge)")
                        .font(.caption2.weight(.medium))
                        .lineLimit(1)
                        .fixedSize()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(ColorsPalette.primary)
                        .foregroundStyle(ColorsPalette.textTertiary)
                        .clipShape(Capsule())
                        .accessibilityValue(Text("\(badge)"))
                }
            }
        } icon: {
            Image(systemName: section.icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
        }
        .font(.headline)
        .foregroundStyle(ColorsPalette.textPrimary)
        .tag(section)
    }
    
    // MARK: - Actions
    
    
    private func setSelection(_ section: ContentTab?) {
        guard let section, section != selection else { return }
        navigationHome.removeAll()
        navigationPost.removeAll()
        navigationInbox.removeAll()
        selection = section
    }
}

#endif
