//
//  Created by Michele Restuccia on 5/11/25.
//

import SwiftUI
import AtegalCore

struct ActivityView: View {
    
    @State
    var presentigSheet: Bool = false
    
    let activity: Center.Category.Activity
    let center: Center
    
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
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .foregroundColor(ColorsPalette.textTertiary)
                .padding(16)
        }
        .cornerBackground(ColorsPalette.primary)
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var sheetView: some View {
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
