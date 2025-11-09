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
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(ColorsPalette.textPrimary)
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(resources) {
                        resourceCell($0)
                        if $0.id != resources.last?.id {
                            Divider()
                                .foregroundStyle(ColorsPalette.textTertiary)
                        }
                    }
                }
                .cornerBackground()
            }
        }
    }
    
    @ViewBuilder
    private func resourceCell(_ item: Center.Category.Resource) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(ColorsPalette.textPrimary)
                
                if let description = item.description {
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(ColorsPalette.textSecondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let address = item.address {
                    Text(address)
                        .foregroundStyle(ColorsPalette.textSecondary)
                }
                if let web = item.web {
                    Button {
                        print("open web")
                    } label: {
                        Text(web)
                            .underline(false)
                            .foregroundStyle(ColorsPalette.primary)
                    }
                }
                if let phone = item.phone {
                    HStack {
                        ForEach(phone, id: \.self) { number in
                            Button {
                                print("call \(number)")
                            } label: {
                                Text(number)
                                    .foregroundStyle(ColorsPalette.primary)
                            }
                        }
                        if let contact = item.contact {
                            Text(contact)
                                .foregroundStyle(ColorsPalette.textSecondary)
                        }
                    }
                }
            }
            .font(.footnote)
        }
        .padding(16)
    }
}
