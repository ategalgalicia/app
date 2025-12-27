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
        PostListView(
            posts: MockPosts.posts,
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

struct PostListView: View {
    
    let posts: [Post]
    
    @State
    var selected: Post?
    
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
                    if let selected {
                        postView(post: selected)
                    }
                }
            }
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        if posts.isEmpty {
            EmptyStateView(txt: "posts-no-data")
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ategal-title")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(ColorsPalette.textPrimary)
                        
                        Text("posts-subtitle")
                            .primaryTitle()
                    }
                    ContentList(
                        items: posts,
                        title: \.title,
                        onTap: {
                            selected = $0
                            navigationPath.append(.navigateToPost)
                        }
                    )
                }
                .padding(16)
                .combinedAccessibility()
            }
        }
    }
    
    @ViewBuilder
    private func postView(post: Post) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImageView(url: post.imageURL)
                
                Text(post.title)
                    .font(.title2.bold())
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .multilineTextAlignment(.leading)
                    .accessibilityHeading(.h1)
                
                Text(post.date.formatted())
                    .font(.body)
                    .foregroundStyle(ColorsPalette.textSecondary)
                
                Text(post.content)
                    .font(.body)
                    .foregroundStyle(ColorsPalette.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing()
            }
            .padding(16)
            .combinedAccessibility()
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
        .navigationTitle("tab-posts")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: Async

struct PostListAsyncView: View {
    
    @Binding
    var navigationPath: [PostRoute]
    
    let apiClient: WPAPIClient
    
    var body: some View {
        AsyncView {
            try await apiClient.fetchPosts()
        } content: {
            PostListView(
                posts: $0,
                navigationPath: $navigationPath
            )
        }
    }
}

// MARK: MockPosts

private enum MockPosts {
    
    static var posts: [Post] {
        [post(id: 1), post(id: 2), post(id: 3)]
    }
    
    static private func post(id: Post.ID) -> Post {
        .init(
            id: id,
            date: .now,
            title: "Las Aulas Senior de Galicia se unen a la conmemoración del Día de la Mujer",
            content: "Por el Día Internacional de las Personas Mayores, desde Ategal celebramos un acto conmemorativo en Fisterra. Durante la jornada, los asistentes pudieron disfrutar de una conferencia impartida por la gestora cultural y comisaria de arte Paula Cabaleiro; así como de una comida de confraternidad con actuación musical",
            imageURL: URL(string: "https://www.ategal.com/wp-content/uploads/2025/11/WhatsApp-Image-2025-11-20-at-14.22.04-2-1024x683.jpeg")
        )
    }
}
