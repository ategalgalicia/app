//
//  Created by Michele Restuccia on 23/10/25.
//

import SwiftUI
import AtegalCore

struct CityListView: View {
    
    @Binding
    var navigationPath: [HomeRoute]
    
    let centers: [Center]
    
    var body: some View {
        contentView
            .background(ColorsPalette.background)
            .tint(ColorsPalette.primary)
            .navigationTitle("city-list-title")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ategal-title")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(ColorsPalette.textPrimary)
                    
                    Text("city-list-subtitle")
                        .primaryTitle()
                }
                    
                ContentList(
                    items: centers,
                    title: \.city,
                    onTap: {
                        navigationPath.append(.navigateToCategoryList($0))
                    }
                )
            }
            .padding(16)
        }
    }
}
