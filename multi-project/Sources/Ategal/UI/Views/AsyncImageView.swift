//
//  Created by Michele Restuccia on 27/12/25.
//

import SwiftUI

struct AsyncImageView: View {
    
    let url: URL?
    
    var body: some View {
        AsyncImage(url: url) { phase in
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
