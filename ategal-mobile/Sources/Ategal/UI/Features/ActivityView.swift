//
//  Created by Michele Restuccia on 5/11/25.
//

import SwiftUI
import AtegalCore
import RStudioKit

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
                headerView
                scheduleView
                actionView
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(activity.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(ColorsPalette.textPrimary)
                .multilineTextAlignment(.leading)
                .accessibilityHeading(.h1)

            Text(activity.description)
                .font(.body)
                .foregroundStyle(ColorsPalette.textSecondary)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
        }
    }

    @ViewBuilder
    private var scheduleView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text("activity-schedule")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .accessibilityHeading(.h2)
            } icon: {
                Image(systemName: "calendar")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(ColorsPalette.primary)
                    .padding(8)
                    .cornerBackground(ColorsPalette.primary.opacity(0.15), radius: 8)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(activity.schedule.enumerated()), id: \.offset) { index, schedule in
                    Text(schedule)
                        .font(.body)
                        .foregroundStyle(ColorsPalette.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)

                    if index < activity.schedule.count - 1 {
                        PlatformDivider()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .ategalCornerBackground()
    }

    @ViewBuilder
    private var actionView: some View {
        Button {
            presentigSheet = true
            Tracking.trackEvent(.activityContactOpen(centerName: center.city))
        } label: {
            Label("activity-action", systemImage: "arrow.forward")
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(16)
                .foregroundStyle(ColorsPalette.textTertiary)
                .ategalCornerPrimaryBackground()
        }
        .ategalCornerBorder()
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var sheetView: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("activity-action-subtitle")
                        .primaryTitle()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LinkView(
                        phoneNumbers: center.phone,
                        email: center.email
                    )
                }
                .padding(.horizontal, 16)
            }
            .background(ColorsPalette.background)
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .presentationDetents([.medium])
            .toolbarWithDismissButton()
        }
        .tint(ColorsPalette.primary)
    }
}
