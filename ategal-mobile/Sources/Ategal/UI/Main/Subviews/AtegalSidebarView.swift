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

        case .profile:
            ProfileView(
                authManager: world.authManager,
                pushManager: world.pushManager
            )
        }
    }
    
    @ViewBuilder
    private func label(_ section: ContentTab) -> some View {
        Label {
            Text(section.title)
        } icon: {
            Image(section.icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
        }
        .font(.headline)
        .foregroundStyle(
            section == selection
            ? ColorsPalette.textTertiary
            : ColorsPalette.textPrimary
        )
        .tag(section)
    }
    
    // MARK: - Actions
    
    
    private func setSelection(_ section: ContentTab?) {
        guard let section, section != selection else { return }
        navigationHome.removeAll()
        navigationPost.removeAll()
        selection = section
    }
}

#endif
