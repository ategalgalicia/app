//
//  Created by Michele Restuccia on 28/10/25.
//

import SwiftUI

enum ContentTab: String, Hashable {
    case home, news
}

struct ContentView: View {
    
    @AppStorage("appearance")
    var appearance = ""
    
    @State
    var tab = ContentTab.home

    @Bindable
    var world: World

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack {
                HomeViewAsync()
            }
            .tabItem { Label("tab-home", systemImage: "house.fill") }
            .tag(ContentTab.home)
            
            NavigationStack {
                NewsViewAsync()
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
            World()
        } content: {
            ContentView(world: $0)
        }
    }
}
