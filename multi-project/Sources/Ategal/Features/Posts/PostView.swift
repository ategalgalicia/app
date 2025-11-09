//
//  Created by Michele Restuccia on 29/10/25.
//

import SwiftUI
import AtegalCore

struct PostView: View {
    
    @Bindable
    var dataSource: PostsDataSource
    
    private var post: Post {
        dataSource.selected!
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(post.date.formatted())
                    .font(.footnote)
                
                Text(post.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(post.content)
                    .font(.subheadline)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
        .navigationTitle("ategal-title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
