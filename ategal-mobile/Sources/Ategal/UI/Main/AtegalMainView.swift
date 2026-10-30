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

    @State
    var navigationInbox: [InboxRoute] = []

    @State
    var openInboxAfterLogin = false
    
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
                        navigationInbox: $navigationInbox,
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
        .applyAccessibility()
        .onChange(of: selection) { _, tab in
            Tracking.trackEvent(.tabSelected(tab: tab.rawValue))
        }
        .onChange(of: world.authManager.userStatus) { _, status in
            if status != .logged, selection == .inbox {
                selection = .home
            } else if status == .logged, openInboxAfterLogin {
                openInboxAfterLogin = false
                navigationInbox = []
                selection = .inbox
            }
        }
        // Keeps the FCM topic subscription aligned with the session state.
        .task(id: world.authManager.userStatus) {
            await world.pushManager.refreshUserStatus(
                world.authManager.userStatus
            )
            guard !Task.isCancelled else { return }
            if world.authManager.userStatus == .logged {
                _ = try? await world.announcementManager.fetchAnnouncements()
            } else {
                world.announcementManager.reset()
            }
        }
        .onAppear {
            world.pushManager.onNotificationTap {
                navigationInbox = []
                openInboxAfterLogin = world.authManager.userStatus != .logged
                selection = openInboxAfterLogin ? .profile : .inbox
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
            navigationInbox: $navigationInbox,
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
            navigationInbox: $navigationInbox,
            world: world
        )
    }
    
    @ViewBuilder
    private var tutorialView: some View {
        BootstrapFormSheetView {
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
        }.background(ColorsPalette.background)
    }
}

// MARK: - ContentTab

enum ContentTab: String, Hashable, Identifiable {
    case home, whoWeAre, posts, profile, inbox

    var id: ContentTab { self }
    
    var title: String {
        switch self {
        case .home: "tab-home".localized
        case .whoWeAre: "tab-who-we-are".localized
        case .posts: "tab-posts".localized
        case .profile: "tab-profile".localized
        case .inbox: "inbox-title".localized
        }
    }
    
    var icon: String {
        switch self {
        case .home: "house"
        case .whoWeAre: "info.circle"
        case .posts: "list.bullet"
        case .profile: "person.crop.circle"
        case .inbox: "envelope"
        }
    }
}
