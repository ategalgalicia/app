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
            dataModel: .mock(),
            navigationPath: $navigationPath
        )
    }
}
#endif

// MARK: CategoryView

struct CategoryView: View {
    
    @Bindable
    var dataModel: HomeDataModel
    
    @Binding
    var navigationPath: [HomeRoute]
    
    private var category: AtegalCore.Category {
        dataModel.categorySelected!
    }
    
    var body: some View {
        contentView
            .navigationTitle(category.title)
            .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        List {
            Section {
                ForEach(category.activities) {
                    cell($0)
                }
            } header: {
                Text("activity-title")
            }
        }
    }
    
    @ViewBuilder
    private func cell(_ item: Activity) -> some View {
        Button {
            dataModel.activitySelected = item
            navigationPath.append(.navigateToActivity)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 4)
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
        }
    }
}
