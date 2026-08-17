//
//  Created by Michele Restuccia on 28/10/25.
//

import SwiftUI
import AtegalCore

enum ContentTab: String, Hashable {
    case home, whoWeAre, posts, profile
}

struct ContentView: View {
    
    @AppStorage("appearance")
    var appearance = ""
    
    @State
    var tab = ContentTab.home
    
    @State
    var navigationHome: [HomeRoute] = []
    @State
    var navigationPost: [PostRoute] = []
    
    private let world: World
    
    init() {
        self.world = World()
    }

    var body: some View {
        TabView(selection: $tab) {
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
            
            NavigationStack {
                WhoWeAreAsyncView(apiClient: world.gistApiClient)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .tabItem { Label("tab-who-we-are", systemImage: "person.crop.circle") }
            .tag(ContentTab.whoWeAre)
            
            NavigationStack(path: $navigationPost) {
                PostListAsyncView(
                    navigationPath: $navigationPost,
                    apiClient: world.wpApiClient
                )
            }
            .tabItem { Label("tab-posts", systemImage: "pencil") }
            .tag(ContentTab.posts)

            NavigationStack {
                ProfileView(authManager: world.authManager)
            }
            .tabItem { Label("tab-profile", systemImage: "person.fill") }
            .tag(ContentTab.profile)
        }
        .preferredColorScheme(appearance == "dark" ? .dark : appearance == "light" ? .light : nil)
        .tint(ColorsPalette.primary)
        .background(ColorsPalette.background)
        .ategalTabBarConfiguration()
        .applyAccessibility()
    }
}
