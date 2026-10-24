//
//  Created by Michele Restuccia on 23/10/25.
//

import SwiftUI
import AtegalCore
import RStudioKit

struct CityListView: View {
    
    let onOpenCenter: (Center) -> Void
    
    let centers: [Center]
    
    var body: some View {
        contentView
            .background(ColorsPalette.background)
            .tint(ColorsPalette.primary)
            .navigationTitle("city-list-title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
    }
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("city-list-subtitle")
                    .primaryTitle()
                    
                ContentList(
                    items: centers,
                    title: \.city,
                    onTap: onOpenCenter
                )
            }
            .padding(.horizontal, 16)
        }
    }
}
