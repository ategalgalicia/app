//
//  Created by Michele Restuccia on 29/10/25.
//

import SwiftUI
import AtegalCore

struct CategoryListView: View {
    
    @Bindable
    var dataSource: HomeDataSource
    
    @Binding
    var navigationPath: [HomeRoute]
    
    private var center: Center {
        dataSource.centerSelected!
    }
    
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
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(center.city)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(ColorsPalette.textPrimary)
                    
                    Text("categoryList-subtitle")
                        .font(.title3)
                        .fontWeight(.regular)
                        .foregroundStyle(ColorsPalette.textPrimary)
                }
                    
                ContentList(
                    items: center.categories,
                    title: \.title,
                    onTap: {
                        dataSource.categorySelected = $0
                        navigationPath.append(.navigateToCategory)
                    }
                )
                
                LinkView(
                    phoneNumbers: center.phone,
                    email: center.email,
                    address: center.address
                )
                
                MapView(place: center.place)
            }
            .padding(16)
        }
    }
}
