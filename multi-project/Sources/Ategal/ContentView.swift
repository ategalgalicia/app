import SwiftUI
import AtegalCore

enum ContentTab: String, Hashable {
    case home
}

struct ContentView: View {
    @AppStorage("tab")
    var tab = ContentTab.home
    
    @AppStorage("appearance")
    var appearance = ""

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack {
                HomeViewAsync()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(ContentTab.home)
        }
        .preferredColorScheme(appearance == "dark" ? .dark : appearance == "light" ? .light : nil)
    }
}
