//
//  Created by Michele Restuccia on 30/10/25.
//

import SwiftUI
import AtegalCore

struct CategoryView: View {
    
    @Bindable
    var dataSource: HomeDataSource
    
    @Binding
    var navigationPath: [HomeRoute]
    
    private var category: Center.Category {
        dataSource.categorySelected!
    }
    
    var body: some View {
        contentView
            .background(ColorsPalette.background)
            .tint(ColorsPalette.primary)
            .navigationTitle(category.title)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("category-title")
                    .font(.title3)
                    .fontWeight(.regular)
                    .foregroundStyle(ColorsPalette.textPrimary)
                    
                ContentList(
                    items: category.activities,
                    title: \.title,
                    onTap: {
                        dataSource.activitySelected = $0
                        navigationPath.append(.navigateToActivity)
                    }
                )
                
                resourceView
                moreInfoView
            }
            .padding(16)
        }
    }
    
    @ViewBuilder
    private var resourceView: some View {
        if let resources = category.resources, !resources.isEmpty {
            VStack(alignment: .leading, spacing: 24) {
                Text("resource-header-title")
                    .font(.title3)
                    .fontWeight(.regular)
                    .foregroundStyle(ColorsPalette.textPrimary)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(resources) {
                        resourceCell($0)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func resourceCell(_ item: Center.Category.Resource) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(ColorsPalette.textSecondary)
                
                if let description = item.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(ColorsPalette.textSecondary)
                }
            }
            LinkView(
                phoneNumbers: item.phone ?? [],
                email: nil,
                website: item.web,
                address: item.address
            )
        }
        .padding(16)
        .cornerBackground()
    }
    
    @ViewBuilder
    private var moreInfoView: some View {
        if let center = dataSource.centerSelected {
            MoreInfoView(center: center)
        }
    }
}
