//
//  Created by Michele Restuccia on 29/10/25.
//

import SwiftUI
import AtegalCore

struct CenterView: View {
    
    @Bindable
    var dataSource: HomeDataSource
    
    @Binding
    var navigationPath: [HomeRoute]
    
    private var center: Center {
        dataSource.centerSelected!
    }
    
    var body: some View {
        ScrollView {
            ContentList(
                headerView: headerView,
                items: center.categories,
                title: \.title,
                onTap: {
                    dataSource.categorySelected = $0
                    navigationPath.append(.navigateToCategory)
                }
            )
            .padding(16)
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
        .navigationTitle(center.city)
        .navigationBarTitleDisplayMode(.large)
    }
    
    @ViewBuilder
    private var headerView: some View {
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
        .font(.subheadline)
        .foregroundStyle(ColorsPalette.textSecondary)
    }
}
