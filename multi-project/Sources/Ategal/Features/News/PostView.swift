//
//  Created by Michele Restuccia on 29/10/25.
//

import SwiftUI
import AtegalCore

#if canImport(Darwin)

// MARK: Previews

#Preview {
    NavigationStack {
        PostView(
            post: MockNews.post(id: "01")
        )
    }
}
#endif

// MARK: PostView

struct PostView: View {
    
    let post: Post
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(post.subtitle)
                    .font(.caption)
                
                Text(post.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
        }
    }
}
