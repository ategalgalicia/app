//
//  Created by Michele Restuccia on 5/11/25.
//

import SwiftUI
import AtegalCore

struct ActivityView: View {
    
    @Bindable
    var dataSource: HomeDataSource
    
    private var activity: Center.Category.Activity {
        dataSource.activitySelected!
    }
    
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
            VStack(alignment: .leading, spacing: 16) {
                Text(activity.title.lowercased().capitalized)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(ColorsPalette.textPrimary)
                
                Text(activity.schedule)
                    .font(.title3)
                    .foregroundStyle(ColorsPalette.textSecondary)
                
                Text(activity.description)
                    .font(.headline)
                    .foregroundStyle(ColorsPalette.textSecondary)
                
                if let center = dataSource.centerSelected {
                    MoreInfoView(center: center)
                        .padding(.top, 16)
                }
            }
            .padding(16)
        }
    }
}
