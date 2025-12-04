//
//  Created by Michele Restuccia on 23/10/25.
//

import SwiftUI
import AtegalCore

struct CenterListView: View {
    
    @Bindable
    var dataSource: HomeDataSource
    
    @Binding
    var navigationPath: [HomeRoute]
    
    var body: some View {
        contentView
            .background(ColorsPalette.background)
            .tint(ColorsPalette.primary)
            .navigationTitle("ategal-title")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("center-list-title")
                    .font(.title3)
                    .fontWeight(.regular)
                    .foregroundStyle(ColorsPalette.textPrimary)
                    
                ContentList(
                    items: dataSource.centers,
                    title: \.city,
                    onTap: {
                        dataSource.centerSelected = $0
                        navigationPath.append(.navigateToCenter)
                    }
                )
            }
            .padding(16)
        }
    }
}
