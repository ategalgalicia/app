//
//  Created by Michele Restuccia on 29/10/25.
//

import SwiftUI
import AtegalCore

struct CategoryListView: View {
    
    @Binding
    var navigationPath: [HomeRoute]
    
    let center: Center
    
    var body: some View {
        contentView
            .background(ColorsPalette.background)
            .tint(ColorsPalette.primary)
            .navigationTitle("categoryList-title")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: ViewBuilders
    
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
        VStack(alignment: .leading, spacing: 8) {
            Text(center.city)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(ColorsPalette.textPrimary)
            
            Text("categoryList-subtitle")
                .primaryTitle()
        }
            
        ContentList(
            items: center.categories,
            title: \.title,
            onTap: {
                navigationPath.append(.navigateToCategory(
                    category: $0, center: center
                ))
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
            .padding(16)
            .cornerBackground()
        }
        .padding(.top, 16)
    }
    
    @ViewBuilder
    private var mapView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("categoryList-footer-map")
                .primaryTitle()
            
            VStack(alignment: .leading, spacing: 8) {
                MapView(place: center.place)
                LinkView(address: center.address)
            }
            .padding(16)
            .cornerBackground()
        }
        .padding(.top, 16)
    }
}
