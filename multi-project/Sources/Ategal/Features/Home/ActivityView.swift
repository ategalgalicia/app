//
//  Created by Michele Restuccia on 5/11/25.
//

import SwiftUI
import AtegalCore

#if canImport(Darwin)

// MARK: Previews

#Preview {
    NavigationStack {
        ActivityView(
            dataModel: .mock()
        )
    }
}
#endif

// MARK: ActivityView

struct ActivityView: View {
    
    @Bindable
    var dataModel: HomeDataModel
    
    private var activity: Activity {
        dataModel.activitySelected!
    }
    
    var body: some View {
        contentView
            .navigationTitle(activity.title)
            .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
    }
}
