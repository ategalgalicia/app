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
                    .font(.caption)
                
                Text(post.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(post.content)
                    .font(.footnote)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
        }
    }
}
