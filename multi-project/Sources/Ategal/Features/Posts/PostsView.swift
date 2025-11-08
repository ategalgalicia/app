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
            .navigationTitle("tab-news")
            .navigationBarTitleDisplayMode(.inline)
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
            List {
                Section(header: Text("news-header-title")) {
                    ForEach(dataSource.posts) {
                        cell($0)
                    }
                }
            }
        } else {
            Text("news-no-data")
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
    
    @ViewBuilder
    private func cell(_ item: Post) -> some View {
        Button {
            dataSource.selected = item
            navigationPath.append(.navigateToPost)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.date.formatted())
                        .font(.caption)
                    
                    Text(item.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 4)
                
                Spacer()
                Image(systemName: "chevron.right")
            }
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

// MARK: PostsDataSource

@Observable
@MainActor
class PostsDataSource {
    
    var selected: Post? = nil
    var posts: [Post]
    
    init(apiClient: AtegalAPIClient) async throws {
        let result = try await apiClient.fetchPosts()
        self.posts = result
    }
    
    /// For Preview
    static func mock() -> PostsDataSource {
        .init()
    }
    private init() {
        self.posts = MockPosts.news
    }
}

// MARK: MockPosts

private enum MockPosts {
    
    static var news: [Post] {
        [post(id: 1), post(id: 2), post(id: 3)]
    }
    
    static private func post(id: Post.ID) -> Post {
        .init(
            id: id,
            date: .now,
            title: "Las Aulas Senior de Galicia se unen a la conmemoración del Día de la Mujer",
            content: "Por el Día Internacional de las Personas Mayores, desde Ategal celebramos un acto conmemorativo en Fisterra. Durante la jornada, los asistentes pudieron disfrutar de una conferencia impartida por la gestora cultural y comisaria de arte Paula Cabaleiro; así como de una comida de confraternidad con actuación musical"
        )
    }
}
