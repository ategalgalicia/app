//
//  Created by Michele Restuccia on 30/10/25.
//

import SwiftUI
import AtegalCore

#if canImport(Darwin)

// MARK: Previews

#Preview {
    
    @Previewable
    @State
    var navigationPath: [HomeRoute] = []
    
    NavigationStack {
        CategoryView(
            dataSource: .mock(),
            navigationPath: $navigationPath
        )
    }
}
#endif

// MARK: CategoryView

struct CategoryView: View {
    
    @Bindable
    var dataSource: HomeDataSource
    
    @Binding
    var navigationPath: [HomeRoute]
    
    private var category: AtegalCore.Category {
        dataSource.categorySelected!
    }
    
    var body: some View {
        contentView
            .navigationTitle(category.title)
            .navigationBarTitleDisplayMode(.inline)
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
                }
            }
        }
    }
    
    @ViewBuilder
    private func activityCell(_ item: Activity) -> some View {
        Button {
            dataSource.activitySelected = item
            navigationPath.append(.navigateToActivity)
        } label: {
            HStack {
                Text(item.title.lowercased().capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
    }
    
    @ViewBuilder
    private func resourceCell(_ item: Resource) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title.lowercased().capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let description = item.description {
                    Text(description)
                        .font(.footnote)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let address = item.address {
                    Text(address)
                }
                if let web = item.web {
                    Button {
                        print(1)
                    } label: {
                        Text(web)
                    }
                }
                if let phone = item.phone {
                    HStack {
                        ForEach(phone, id: \.self) { item in
                            Button {
                                print(1)
                            } label: {
                                Text(item)
                            }
                        }
                        if let contact = item.contact {
                            Text("(\(contact))")
                        }
                    }
                }
            }
            .font(.footnote)
        }
    }
}
