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
            dataSource: .mock(),
            navigationPath: $navigationPath
        )
    }
}
#endif

// MARK: NewsRoute

enum NewsRoute: Hashable {
    case navigateToPost
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
                case .navigateToPost:
                    PostView(dataSource: dataSource)
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

// MARK: Async

struct NewsViewAsync: View {
    
    @Binding
    var navigationPath: [NewsRoute]
    
    let apiClient: AtegalAPIClient
    
    var body: some View {
        AsyncView {
            try await NewsDataSource(apiClient: apiClient)
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
    
    var selected: Post? = nil
    var news: [Post]
    
    init(apiClient: AtegalAPIClient) async throws {
        let result = try await apiClient.fetchNews()
        self.news = result
    }
    
    /// For Preview
    static func mock() -> NewsDataSource {
        .init()
    }
    private init() {
        self.news = MockNews.news
    }
}

// MARK: NewsDataSource

private enum MockNews {
    
    static var news: [Post] {
        [post(id: 1), post(id: 2), post(id: 3)]
    }
    
    static func post(id: Post.ID) -> Post {
        .init(
            id: id,
            date: .now,
            title: "Las Aulas Senior de Galicia se unen a la conmemoración del Día de la Mujer",
            content: "Las Aulas Senior de Galicia se unen a la conmemoración del Día de la Mujer"
        )
    }
}
