//
//  Created by Michele Restuccia on 28/10/25.
//

import SwiftUI
import AtegalCore

enum ContentTab: String, Hashable {
    case home, news
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

    @Bindable
    var world: World

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
            
            NavigationStack(path: $navigationPost) {
                PostsAsyncView(
                    navigationPath: $navigationPost,
                    apiClient: world.apiClient
                )
            }
            .tabItem { Label("tab-news", systemImage: "house.fill") }
            .tag(ContentTab.news)
        }
        .preferredColorScheme(appearance == "dark" ? .dark : appearance == "light" ? .light : nil)
        .tint(ColorsPalette.primary)
        .background(ColorsPalette.background)
    }
}

// MARK: Async

struct ContentViewAsync: View {
    
    var body: some View {
        AsyncView {
            await World()
        } content: {
            ContentView(world: $0)
        }
    }
}
