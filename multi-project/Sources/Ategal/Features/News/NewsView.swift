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
    var navigationPath: [NewsRoute] = []
    
    NavigationStack {
        NewsView(
            dataSource: .init(),
            navigationPath: $navigationPath
        )
    }
}
#endif

// MARK: NewsRoute

enum NewsRoute: Hashable {
    case navigateToPost(id: Post.ID)
}

// MARK: NewsView

struct NewsView: View {
    
    @Bindable
    var dataSource: NewsDataSource
    
    @Binding
    var navigationPath: [NewsRoute]
    
    var body: some View {
        contentView
            .navigationTitle("tab-news")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: NewsRoute.self) { route in
                switch route {
                case .navigateToPost(let id):
                    if let post = dataSource.news.first(where: { $0.id == id }) {
                        PostView(post: post)
                    }
                }

            }
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        List {
            if !dataSource.news.isEmpty {
                Section(header: Text("news-header-title")) {
                    ForEach(dataSource.news) {
                        cell($0)
                    }
                }
            } else {
                Text("news-no-data")
            }
        }
    }
    
    @ViewBuilder
    private func cell(_ item: Post) -> some View {
        Button {
            navigationPath.append(.navigateToPost(id: item.id))
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.subtitle)
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

// MARK: Async

struct NewsViewAsync: View {
    
    @Binding
    var navigationPath: [NewsRoute]
    
    var body: some View {
        AsyncView {
            NewsDataSource()
        } content: {
            NewsView(
                dataSource: $0,
                navigationPath: $navigationPath
            )
        }
    }
}

// MARK: NewsDataSource

@Observable
@MainActor
class NewsDataSource {
    
    let news: [Post]
    
    init(apiClient: AtegalAPIClient) async throws {
//        let result = try await apiClient.fetchNews()
        self.news = MockNews.news//try await result.dataModel
    }
    
    /// For Preview
    init() {
        self.news = MockNews.news
    }
}

// MARK: NewsDataSource

enum MockNews {
    
    static var news: [Post] {
        [post(id: "1"), post(id: "2"), post(id: "3")]
    }
    
    static func post(id: Post.ID) -> Post {
        .init(
            id: id,
            title: "Las Aulas Senior de Galicia se unen a la conmemoración del Día de la Mujer",
            subtitle: "19/04/2025"
        )
    }
}
