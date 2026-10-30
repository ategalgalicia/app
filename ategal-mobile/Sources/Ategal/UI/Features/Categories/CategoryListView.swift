//
//  Created by Michele Restuccia on 29/10/25.
//

import SwiftUI
import AtegalCore
import RStudioKit

struct CategoryListView: View {
    
    let onOpenCategory: (Center.Category, Center) -> Void
    
    let center: Center
    
    var body: some View {
        contentView
            .background(ColorsPalette.background)
            .tint(ColorsPalette.primary)
            .navigationTitle(center.city)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                Text("categoryList-subtitle")
                    .primaryTitle()
                    .padding(.bottom, center.categories.isEmpty ? 0 : 16)

                ContentList(
                    items: center.categories,
                    title: \.title,
                    onTap: {
                        onOpenCategory($0, center)
                    }
                )

                contactView
                    .padding(.top, 16)
                mapView
                    .padding(.top, 16)
            }
            .padding([.horizontal, .bottom], 16)
        }
    }
    
    @ViewBuilder
    private var contactView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("categoryList-footer")
                .primaryTitle()
            
            LinkView(
                phoneNumbers: center.phone,
                email: center.email
            )
            
        }
        .padding(.top, 16)
    }
    
    @ViewBuilder
    private var mapView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("categoryList-footer-map")
                .primaryTitle()
            
            MapView(place: center.place)
        }
        .padding(.top, 16)
    }
}
