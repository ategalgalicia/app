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
        ScrollView {
            contentView
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
        .navigationTitle("ategal-title")
        .navigationBarTitleDisplayMode(.inline)
        .actionView { actionView }
    }
    
    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(activity.title.lowercased().capitalized)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(ColorsPalette.textPrimary)
                
                Text(activity.schedule)
                    .font(.subheadline)
                    .foregroundStyle(ColorsPalette.textSecondary)
            }
            Text(activity.description)
                .font(.subheadline)
                .foregroundStyle(ColorsPalette.textSecondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.address)
                if let email = activity.email {
                    Button {
                        print("open mail")
                    } label: {
                        Text(email)
                            .underline(false)
                            .foregroundStyle(ColorsPalette.primary)
                    }
                }
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
            }
            .font(.subheadline)
            .foregroundStyle(ColorsPalette.textPrimary)
        }
        .padding(16)
    }
    
    @ViewBuilder
    private var actionView: some View {
        Button {
            print(1)
        } label: {
            Text("activity-call-to-action")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(ColorsPalette.textTertiary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .buttonStyle(.borderedProminent)
        .frame(maxWidth: .infinity, minHeight: 48)
        .tint(ColorsPalette.primary)
    }
}
