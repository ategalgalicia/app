//
//  Created by Michele Restuccia on 28/10/25.
//

import SwiftUI
import AtegalCore

#if canImport(Darwin)

// MARK: Previews

#Preview {
    
    @Previewable
    @State
    var navigationPath: [PostRoute] = []
    
    NavigationStack {
        PostsView(
            dataSource: .mock(),
            navigationPath: $navigationPath
        )
    }
}
#endif

// MARK: PostRoute

enum PostRoute: Hashable {
    case navigateToPost
}

// MARK: PostsView

struct PostsView: View {
    
    @Bindable
    var dataSource: PostsDataSource
    
    @Binding
    var navigationPath: [PostRoute]
    
    var body: some View {
        contentView
            .background(ColorsPalette.background)
            .tint(ColorsPalette.primary)
            .navigationTitle("tab-posts")
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityHeading(.h1)
            .navigationDestination(for: PostRoute.self) { route in
                switch route {
                case .navigateToPost:
                    PostView(dataSource: dataSource)
                }
            }
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        if !dataSource.posts.isEmpty {
            listView
        } else {
            emptyView
        }
    }
    
    @ViewBuilder
    private var listView: some View {
        ScrollView {
            ContentList(
                items: dataSource.posts,
                title: \.title,
                onTap: {
                    dataSource.selected = $0
                    navigationPath.append(.navigateToPost)
                }
            )
            .padding(16)
            .combinedAccessibility()
        }
    }
    
    @ViewBuilder
    private var emptyView: some View {
        ScrollView {
            VStack {
                Text("posts-no-data")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .accessibilityLabel("posts-no-data")
                    .accessibilityHeading(.h2)
            }
            .padding(16)
        }
    }
}

// MARK: PostsAsyncView

struct PostsAsyncView: View {
    
    @Binding
    var navigationPath: [PostRoute]
    
    let apiClient: AtegalAPIClient
    
    var body: some View {
        AsyncView {
            try await PostsDataSource(apiClient: apiClient)
        } content: {
            PostsView(
                dataSource: $0,
                navigationPath: $navigationPath
            )
        }
    }
}
