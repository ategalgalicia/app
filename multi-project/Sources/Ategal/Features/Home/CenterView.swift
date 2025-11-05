//
//  Created by Michele Restuccia on 29/10/25.
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
        CenterView(
            dataModel: .mock(),
            navigationPath: $navigationPath
        )
    }
}
#endif

// MARK: CenterView

struct CenterView: View {
    
    @Bindable
    var dataModel: HomeDataModel
    
    @Binding
    var navigationPath: [HomeRoute]
    
    private var center: Center {
        dataModel.centerSelected!
    }
    
    var body: some View {
        contentView
            .navigationTitle(center.city)
            .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        List {
            Section {
                ForEach(center.categories) {
                    cell($0)
                }
            } header: {
                VStack(alignment: .leading, spacing: 8) {
                    Text(center.address)
                    ForEach(center.phone, id: \.self) {
                        Text($0)
                    }
                    if let email = center.email {
                        Text(email)
                    }
                }
                .font(.subheadline)
                .fontWeight(.semibold)
            }
        }
    }
    
    @ViewBuilder
    private func cell(_ item: AtegalCore.Category) -> some View {
        Button {
            dataModel.categorySelected = item
            navigationPath.append(.navigateToCategory)
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
