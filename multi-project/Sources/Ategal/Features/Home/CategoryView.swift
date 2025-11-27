//
//  Created by Michele Restuccia on 30/10/25.
//

import SwiftUI
import AtegalCore

struct CategoryView: View {
    
    @Bindable var dataSource: HomeDataSource
    @Binding var navigationPath: [HomeRoute]
    
    private var category: Center.Category {
        dataSource.categorySelected!
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                activitiesView
                resourceView
                moreInfoView
            }
            .padding(16)
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var activitiesView: some View {
        ContentList(
            items: category.activities,
            title: \.title,
            onTap: {
                dataSource.activitySelected = $0
                navigationPath.append(.navigateToActivity)
            }
        )
    }
    
    @ViewBuilder
    private var resourceView: some View {
        if let resources = category.resources, !resources.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("resource-header-title")
                    .font(.title3)
                    .fontWeight(.semibold)
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
                    .foregroundStyle(ColorsPalette.textPrimary)
                
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
