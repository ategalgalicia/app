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
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                listView
                contactView
                mapView
            }
            .padding(16)
        }
    }
    
    @ViewBuilder
    private var listView: some View {
        Text("categoryList-subtitle")
            .primaryTitle()
            
        ContentList(
            items: center.categories,
            title: \.title,
            onTap: {
                onOpenCategory($0, center)
            }
        )
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
            
            VStack(alignment: .leading, spacing: 8) {
                LinkView(
                    address: center.address,
                    lat: center.latitude,
                    long: center.longitude
                )
                MapView(place: center.place)
            }
        }
        .padding(.top, 16)
    }
}
