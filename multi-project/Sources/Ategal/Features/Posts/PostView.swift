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
                asyncImageView
                
                Text(post.date.formatted())
                    .font(.subheadline)
                
                Text(post.title)
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text(post.content)
                    .font(.headline)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
        .navigationTitle("ategal-title")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var asyncImageView: some View {
        AsyncImage(url: post.imageURL) { phase in
            ZStack {
                Rectangle()
                    .fill(ColorsPalette.cardBackground)
                    .opacity((phase.image == nil) ? 1 : 0)
                
                phase.image?
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .transition(.opacity)
            }
            .animation(.easeInOut(duration: 0.25), value: phase.image != nil)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
