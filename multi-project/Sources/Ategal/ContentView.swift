//
//  Created by Michele Restuccia on 28/10/25.
//

import SwiftUI
import AtegalCore

enum ContentTab: String, Hashable {
    case home, whoWeAre, posts
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
                HomeView(
                    navigationPath: $navigationHome,
                    apiClient: world.apiClient,
                    appVersion: world.appVersion
                )
            }
            .tabItem { Label("tab-home", systemImage: "house.fill") }
            .tag(ContentTab.home)
            
            NavigationStack {
                WhoWeAreView(apiClient: world.apiClient)
            }
            .tabItem { Label("tab-who-we-are", systemImage: "person.crop.circle") }
            .tag(ContentTab.whoWeAre)
            
            NavigationStack(path: $navigationPost) {
                PostsAsyncView(
                    navigationPath: $navigationPost,
                    apiClient: world.apiClient
                )
            }
            .tabItem { Label("tab-posts", systemImage: "pencil") }
            .tag(ContentTab.posts)
        }
        .preferredColorScheme(appearance == "dark" ? .dark : appearance == "light" ? .light : nil)
        .tint(ColorsPalette.primary)
        .background(ColorsPalette.background)
        .tabBarMinimizeBehavior()
        .applyAccessibility()
    }
}
