//
//  Created by Michele Restuccia on 30/10/25.
//

import SwiftUI
import AtegalCore
import RStudioKit

struct CategoryView: View {
    
    @Binding
    var navigationPath: [HomeRoute]
    
    let category: Center.Category
    let center: Center
    
    var body: some View {
        contentView
            .background(ColorsPalette.background)
            .tint(ColorsPalette.primary)
            .navigationTitle(category.title)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("category-subtitle")
                    .primaryTitle()
                
                ContentList(
                    items: category.activities,
                    title: \.title,
                    onTap: {
                        navigationPath.append(.navigateToActivity(
                            activity: $0, center: center
                        ))
                    }
                )
                resourceView
            }
            .padding(16)
        }
    }
    
    @ViewBuilder
    private var resourceView: some View {
        if let resources = category.resources, !resources.isEmpty {
            VStack(alignment: .leading, spacing: 24) {
                Text("resource-header-title")
                    .primaryTitle()
                
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(resources) {
                        resourceCell($0)
                    }
                }
            }
            .padding(.top, 16)
        }
    }
    
    @ViewBuilder
    private func resourceCell(_ item: Center.Category.Resource) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(ColorsPalette.textPrimary)
            
            if let description = item.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(ColorsPalette.textSecondary)
            }
            LinkView(
                phoneNumbers: item.phone ?? [],
                email: nil,
                website: item.web,
                address: item.address
            )
            .padding(.top, 8)
        }
    }
}
