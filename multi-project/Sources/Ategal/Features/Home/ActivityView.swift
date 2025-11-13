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
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(ColorsPalette.textPrimary)
                
                Text(activity.schedule)
                    .font(.headline)
                    .foregroundStyle(ColorsPalette.textSecondary)
                
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundStyle(ColorsPalette.textSecondary)
                
                LinkView(
                    phoneNumbers: activity.phone,
                    email: activity.email,
                    website: nil,
                    address: activity.address
                )
                .padding(.top, 16)
                .font(.headline)
            }
            .padding(16)
        }
    }
}
