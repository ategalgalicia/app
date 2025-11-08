//
//  Created by Michele Restuccia on 29/10/25.
//

import SwiftUI
import AtegalCore

struct CenterView: View {
    
    @Bindable var dataSource: HomeDataSource
    @Binding var navigationPath: [HomeRoute]
    
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
                        .foregroundStyle(ColorsPalette.textPrimary)

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
                    .foregroundStyle(ColorsPalette.textSecondary)
                }
                .padding(.bottom, 16)
            }
        }
        .listRowBackground(Color.clear)
        .scrollContentBackground(.hidden)
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
    }
    
    @ViewBuilder
    private func cell(_ item: Center.Category) -> some View {
        Button {
            dataSource.categorySelected = item
            navigationPath.append(.navigateToCategory)
        } label: {
            HStack {
                Text(item.title)
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
}
