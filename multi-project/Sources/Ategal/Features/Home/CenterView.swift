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
            dataSource: .mock(),
            navigationPath: $navigationPath
        )
    }
}
#endif

// MARK: CenterView

struct CenterView: View {
    
    @Bindable
    var dataSource: HomeDataSource
    
    @Binding
    var navigationPath: [HomeRoute]
    
    private var center: Center {
        dataSource.centerSelected!
    }
    
    var body: some View {
        List {
            Section {
                ForEach(center.categories) {
                    cell($0)
                }
            } header: {
                VStack(alignment: .leading, spacing: 16) {
                    Text(center.city)
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(center.address)
                        HStack {
                            ForEach(center.phone, id: \.self) {
                                Text($0)
                            }
                        }
                        if let email = center.email {
                            Text(email)
                        }
                    }
                    .font(.footnote)
                }
                .padding(.bottom, 16)
            }
        }
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private func cell(_ item: AtegalCore.Category) -> some View {
        Button {
            dataSource.categorySelected = item
            navigationPath.append(.navigateToCategory)
        } label: {
            HStack {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
    }
}
