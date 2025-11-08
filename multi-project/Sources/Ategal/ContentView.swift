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
    var navigationHomePath: [HomeRoute] = []
    @State
    var navigationNewsPath: [NewsRoute] = []

    @Bindable
    var world: World

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack(path: $navigationHomePath) {
                HomeView($navigationHomePath)
            }
            .tabItem { Label("tab-home", systemImage: "house.fill") }
            .tag(ContentTab.home)
            
            NavigationStack(path: $navigationNewsPath) {
                NewsViewAsync(
                    navigationPath: $navigationNewsPath,
                    apiClient: world.apiClient
                )
            }
            .tabItem { Label("tab-news", systemImage: "house.fill") }
            .tag(ContentTab.news)
        }
        .preferredColorScheme(appearance == "dark" ? .dark : appearance == "light" ? .light : nil)
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
