//
//  Created by Michele Restuccia on 5/11/25.
//

import SwiftUI
import AtegalCore

struct ActivityView: View {
    
    @Bindable var dataSource: HomeDataSource
    
    private var activity: Center.Category.Activity {
        dataSource.activitySelected!
    }
    
    var body: some View {
        ScrollView {
            contentView
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
        .actionView { actionView }
    }
    
    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(activity.title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(ColorsPalette.textPrimary)
            
            Text(activity.description)
                .font(.subheadline)
                .foregroundStyle(ColorsPalette.textSecondary)
            
            Text(activity.schedule)
                .font(.subheadline)
                .foregroundStyle(ColorsPalette.textSecondary)
            
            Text(activity.address)
                .font(.subheadline)
                .foregroundStyle(ColorsPalette.textSecondary)
            
            HStack {
                ForEach(activity.phone, id: \.self) { item in
                    Button {
                        print(1)
                    } label: {
                        Text(item)
                            .foregroundStyle(ColorsPalette.primary)
                    }
                }
            }
            .font(.subheadline)
        }
        .padding(16)
    }
    
    @ViewBuilder
    private var actionView: some View {
        Button(
            action: {
                print(1)
            }, label: {
                if let email = activity.email {
                    Text(email)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(ColorsPalette.primary)
                }
            }
        )
        .frame(maxWidth: .infinity, minHeight: 48)
        .tint(ColorsPalette.primary)
    }
}
