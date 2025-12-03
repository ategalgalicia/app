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
                Text(activity.title.lowercased().capitalizedFirst)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(ColorsPalette.textPrimary)
                
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(activity.schedule, id: \.self) { schedule in
                        Text(schedule)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(ColorsPalette.textSecondary)
                    }
                }
                .padding(16)
                .cornerBackground()
                
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundStyle(ColorsPalette.textPrimary)
                
                if let center = dataSource.centerSelected {
                    MoreInfoView(center: center)
                        .padding(.top, 16)
                }
            }
            .padding(16)
        }
    }
}
