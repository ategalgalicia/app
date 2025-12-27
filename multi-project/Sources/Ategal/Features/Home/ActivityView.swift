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
                headerView
                scheduleView
                actionView
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(activity.title)
                .font(.title2.bold())
                .foregroundStyle(ColorsPalette.textPrimary)
                .multilineTextAlignment(.leading)
                .accessibilityHeading(.h1)

            Text(activity.description)
                .font(.body)
                .foregroundStyle(ColorsPalette.textSecondary)
                .multilineTextAlignment(.leading)
                .lineSpacing()
        }
    }

    @ViewBuilder
    private var scheduleView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text("activity-schedule")
                    .font(.headline)
                    .foregroundStyle(ColorsPalette.textPrimary)
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
                ForEach(activity.schedule, id: \.self) { schedule in
                    Text(schedule)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(ColorsPalette.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .cornerBackground()
    }

    @ViewBuilder
    private var actionView: some View {
        Button {
            presentigSheet = true
        } label: {
            Label("activity-action", systemImage: "arrow.forward")
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(16)
                .foregroundStyle(ColorsPalette.textTertiary)
        }
        .cornerBackground(ColorsPalette.primary)
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var sheetView: some View {
        PresentationSheetContainer(title: "activity-action") {
            Text("activity-action-subtitle")
                .font(.callout.weight(.medium))
                .foregroundStyle(ColorsPalette.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LinkView(
                phoneNumbers: center.phone,
                email: center.email
            )
        }
    }
}
