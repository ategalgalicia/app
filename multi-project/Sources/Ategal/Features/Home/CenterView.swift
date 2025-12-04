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
            VStack(alignment: .leading, spacing: 24) {
                ContentList(
                    items: center.categories,
                    title: \.title,
                    onTap: {
                        dataSource.categorySelected = $0
                        navigationPath.append(.navigateToCategory)
                    }
                )
                MoreInfoView(center: center)
            }
            .padding(16)
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
        .navigationTitle(center.city)
        .navigationBarTitleDisplayMode(.inline)
    }
}
