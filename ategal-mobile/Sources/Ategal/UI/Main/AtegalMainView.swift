//
//  Created by Michele Restuccia on 28/10/25.
//

import SwiftUI
import RStudioKit
import AtegalCore

enum AppStatus: Equatable {
    case normal, tutorial
}

struct AtegalMainView: View {

    @UserDefaultsBacked(key: "has-completed-tutorial")
    var hasCompletedTutorial = false
    
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    @State
    var appStatus: AppStatus = .tutorial
    
    @State
    var selection = ContentTab.home
    
    @State
    var navigationHome: [HomeRoute] = []
    
    @State
    var navigationPost: [PostRoute] = []
    
    let world: World

    init(world: World) {
        self.world = world
        self._appStatus = State(initialValue: hasCompletedTutorial ? .normal : .tutorial)
    }

    @ViewBuilder
    var body: some View {
        Group {
            switch appStatus {
            case .normal:
                #if canImport(Darwin)
                if horizontalSizeClass == .regular {
                    AtegalSidebarView(
                        selection: $selection,
                        navigationHome: $navigationHome,
                        navigationPost: $navigationPost,
                        world: world
                    )
                } else {
                    compactView
                }
                #else
                compactView
                #endif
                
            case .tutorial:
                tutorialView
            }
        }
        .onChange(of: selection) { _, tab in
            Tracking.trackEvent(.tabSelected(tab: tab.rawValue))
        }
        // Keeps the FCM topic subscription aligned with the session state.
        .task(id: world.authManager.userStatus) {
            await world.pushManager.refreshUserStatus(
                world.authManager.userStatus
            )
        }
        .onAppear {
            world.pushManager.onReceiveDeeplink { payload in
                selection = .home
                navigationHome = [.deeplink(payload)]
            }
        }
    }
    
    // MARK: - ViewBuilders
    
    #if canImport(Darwin)
    @ViewBuilder
    private var regularView: some View {
        AtegalSidebarView(
            selection: $selection,
            navigationHome: $navigationHome,
            navigationPost: $navigationPost,
            world: world
        )
    }
    #endif
    
    @ViewBuilder
    private var compactView: some View {
        AtegalTabView(
            selection: $selection,
            navigationHome: $navigationHome,
            navigationPost: $navigationPost,
            world: world
        )
    }
    
    @ViewBuilder
    private var tutorialView: some View {
        TutorialView(isPresented: Binding(
            get: { appStatus == .tutorial },
            set: { isPresented in
                if !isPresented {
                    hasCompletedTutorial = true
                    appStatus = .normal
                    Tracking.trackEvent(.tutorialComplete)
                }
            }
        ))
    }
}

// MARK: - ContentTab

enum ContentTab: String, Hashable {
    case home, whoWeAre, posts, profile
    
    var title: LocalizedStringKey {
        switch self {
        case .home: "tab-home"
        case .whoWeAre: "tab-who-we-are"
        case .posts: "tab-posts"
        case .profile: "tab-profile"
        }
    }
    
    var icon: String {
        switch self {
        case .home: "house"
        case .whoWeAre: "info.circle"
        case .posts: "list.bullet"
        case .profile: "person.crop.circle"
        }
    }
}
