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
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var asyncImageView: some View {
        AsyncImage(url: post.imageURL) { phase in
            ZStack {
                Rectangle()
                    .fill(ColorsPalette.background)
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
        .accessibilityHidden(true)
    }
}
