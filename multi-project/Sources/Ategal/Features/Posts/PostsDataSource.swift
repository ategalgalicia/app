//
//  Created by Michele Restuccia on 8/11/25.
//

import Foundation
import AtegalCore

#if os(Android)
import SkipFuseUI
#endif

@Observable
@MainActor
class PostsDataSource {
    
    var selected: Post? = nil
    var posts: [Post]
    
    init(apiClient: WPAPIClient) async throws {
        self.posts = try await apiClient.fetchPosts()
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
            content: "Por el Día Internacional de las Personas Mayores, desde Ategal celebramos un acto conmemorativo en Fisterra. Durante la jornada, los asistentes pudieron disfrutar de una conferencia impartida por la gestora cultural y comisaria de arte Paula Cabaleiro; así como de una comida de confraternidad con actuación musical",
            imageURL: URL(string: "https://www.ategal.com/wp-content/uploads/2025/11/WhatsApp-Image-2025-11-20-at-14.22.04-2-1024x683.jpeg")
        )
    }
}
