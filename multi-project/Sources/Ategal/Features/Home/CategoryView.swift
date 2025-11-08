//
//  Created by Michele Restuccia on 30/10/25.
//

import SwiftUI
import AtegalCore

struct CategoryView: View {
    
    @Bindable var dataSource: HomeDataSource
    @Binding var navigationPath: [HomeRoute]
    
    private var category: Center.Category { dataSource.categorySelected! }
    
    var body: some View {
        contentView
            .navigationTitle(category.title)
            .navigationBarTitleDisplayMode(.inline)
            .listRowBackground(Color.clear)
            .scrollContentBackground(.hidden)
            .background(ColorsPalette.background)
            .tint(ColorsPalette.primary)
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        List {
            Section {
                ForEach(category.activities) {
                    activityCell($0)
                }
            }
            if let resources = category.resources, !resources.isEmpty {
                Section {
                    ForEach(resources) {
                        resourceCell($0)
                    }
                } header: {
                    Text("resource-header-title")
                        .foregroundStyle(ColorsPalette.textSecondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func activityCell(_ item: Center.Category.Activity) -> some View {
        Button {
            dataSource.activitySelected = item
            navigationPath.append(.navigateToActivity)
        } label: {
            HStack {
                Text(item.title.lowercased().capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(ColorsPalette.textPrimary)

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(ColorsPalette.primary)
            }
            .padding(.vertical, 8)
        }
        .listRowBackground(ColorsPalette.cardBackground)
    }
    
    @ViewBuilder
    private func resourceCell(_ item: Center.Category.Resource) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title.lowercased().capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
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
                    Button(action: { print("open web") }) {
                        Text(web)
                            .underline(false)
                            .foregroundStyle(ColorsPalette.primary)
                    }
                }
                if let phone = item.phone {
                    HStack {
                        ForEach(phone, id: \.self) { number in
                            Button(action: { print("call \(number)") }) {
                                Text(number)
                                    .foregroundStyle(ColorsPalette.primary)
                            }
                        }
                        if let contact = item.contact {
                            Text("(\(contact))")
                                .foregroundStyle(ColorsPalette.textSecondary)
                        }
                    }
                }
            }
            .font(.footnote)
        }
        .listRowBackground(ColorsPalette.cardBackground)
    }
}
