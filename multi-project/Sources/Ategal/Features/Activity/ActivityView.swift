//
//  Created by Michele Restuccia on 5/11/25.
//

import SwiftUI
import AtegalCore

struct ActivityView: View {
    
    @Bindable
    var dataSource: HomeDataSource
    
    @State
    var presentigSheet: Bool = false
    
    private var activity: Center.Category.Activity {
        dataSource.activitySelected!
    }
    
    var body: some View {
        contentView
            .background(ColorsPalette.background)
            .tint(ColorsPalette.primary)
            .navigationTitle("ategal-title")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $presentigSheet) {
                sheetView
            }
    }
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(activity.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .multilineTextAlignment(.leading)
                    .accessibilityHeading(.h1)
                
                Text(activity.description)
                    .font(.body)
                    .foregroundStyle(ColorsPalette.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing()
                
                VStack(alignment: .leading, spacing: 16) {
                    scheduleView
                    actionView
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .cornerBackground()
            }
            .frame(maxWidth: .infinity)
            .padding(16)
        }
    }
    
    @ViewBuilder
    private var scheduleView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(activity.schedule, id: \.self) { schedule in
                Text(schedule)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ColorsPalette.textPrimary)
            }
        }
    }
    
    @ViewBuilder
    private var actionView: some View {
        Button {
            presentigSheet = true
        } label: {
            Text("activity-action")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .foregroundColor(ColorsPalette.textTertiary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .cornerBackground(ColorsPalette.primary)
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var sheetView: some View {
        if let center = dataSource.centerSelected {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("activity-action-subtitle")
                            .font(.subheadline)
                            .foregroundColor(ColorsPalette.textPrimary)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        
                        LinkView(
                            phoneNumbers: center.phone,
                            email: center.email
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                }
                .navigationTitle("activity-action")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarWithDismissButton()
            }
            .background(ColorsPalette.background)
            .tint(ColorsPalette.primary)
            .presentationDetents([.medium])
        }
    }
}
