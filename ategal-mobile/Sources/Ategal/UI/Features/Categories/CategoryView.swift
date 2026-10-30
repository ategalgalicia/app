//
//  Created by Michele Restuccia on 30/10/25.
//

import SwiftUI
import AtegalCore
import RStudioKit

struct CategoryView: View {
    
    let onOpenActivity: (Center.Category.Activity, Center) -> Void
    
    let category: Center.Category
    let center: Center
    
    var body: some View {
        contentView
            .background(ColorsPalette.background)
            .tint(ColorsPalette.primary)
            .navigationTitle(category.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                Text("category-subtitle")
                    .primaryTitle()
                    .padding(.bottom, category.activities.isEmpty ? 0 : 16)
                
                ContentList(
                    items: category.activities,
                    title: \.title,
                    onTap: {
                        onOpenActivity($0, center)
                    }
                )

                if let resources = category.resources, !resources.isEmpty {
                    Text("resource-header-title")
                        .primaryTitle()
                        .padding(.top, 32)
                        .padding(.bottom, 16)

                    ForEach(resources) { resource in
                        resourceCell(resource)
                            .padding(.top, resource.id == resources.first?.id ? 0 : 24)
                    }
                }
            }
            .padding(16)
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
