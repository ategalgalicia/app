//
//  Created by Michele Restuccia on 28/10/25.
//

import SwiftUI
import AtegalCore

enum ContentTab: String, Hashable {
    case home, calendar, posts
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
                    apiClient: world.apiClient
                )
            }
            .tabItem { Label("tab-home", systemImage: "house.fill") }
            .tag(ContentTab.home)
            
            NavigationStack {
                CalendarAsyncView(
                    apiClient: world.apiClient
                )
            }
            .tabItem { Label("tab-calendar", systemImage: "calendar") }
            .tag(ContentTab.calendar)
            
            NavigationStack(path: $navigationPost) {
                PostsAsyncView(
                    navigationPath: $navigationPost,
                    apiClient: world.apiClient
                )
            }
            .tabItem { Label("tab-posts", systemImage: "list.bullet") }
            .tag(ContentTab.posts)
        }
        .preferredColorScheme(appearance == "dark" ? .dark : appearance == "light" ? .light : nil)
        .tint(ColorsPalette.primary)
        .background(ColorsPalette.background)
    }
}
