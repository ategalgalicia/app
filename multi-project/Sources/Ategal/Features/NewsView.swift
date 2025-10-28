//
//  Untitled.swift
//  multi-project
//
//  Created by Michele Restuccia on 28/10/25.
//

import SwiftUI
import AtegalCore

#if canImport(Darwin)

// MARK: Previews

@available(iOS 18, *)
#Preview {
    NavigationStack {
        NewsView(dataModel: .init())
    }
}
#endif

// MARK: NewsView

struct NewsView: View {
    
    let dataModel: NewsDataModel
    
    var body: some View {
        contentView
            .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        List {
            if !dataModel.posts.isEmpty {
                Section(header: Text("news-header-title")) {
                    ForEach(dataModel.posts) {
                        cell($0)
                    }
                }
            } else {
                Text("news-no-data")
            }
        }
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    private func cell(_ post: NewsDataModel.Post) -> some View {
        Button {
            print(1)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.subtitle)
                        .font(.caption)
                    
                    Text(post.title)
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
    
    var body: some View {
        AsyncView {
            NewsDataModel()
        } content: {
            NewsView(dataModel: $0)
        }
    }
}

// MARK: NewsDataModel

struct NewsDataModel {
    
    let posts: [Post]
    struct Post: Identifiable {
        let id: Int
        let title: String
        let subtitle: String
    }
    
    init(apiClient: AtegalAPIClient) async throws {
        let result = try await apiClient.fetchNews()
        self.posts = MockNews.posts//try await result.dataModel
    }
    
    /// For Preview
    init() {
        self.posts = MockNews.posts
    }
}

// MARK: Mock

private enum MockNews {
    
    static var posts: [NewsDataModel.Post] {
        [
            .init(
                id: 1,
                title: "Las Aulas Senior de Galicia se unen a la conmemoración del Día de la Mujer",
                subtitle: "19/04/2025"
            )
        ]
    }
}
