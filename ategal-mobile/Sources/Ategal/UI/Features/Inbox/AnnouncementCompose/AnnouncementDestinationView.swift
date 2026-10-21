import SwiftUI
import AtegalCore
import RStudioKit

struct AnnouncementDestinationView: View {
    @Binding
    var navigationPath: [InboxRoute]

    let action: Announcement.Action
    let centers: [Center]

    var body: some View {
        activityView
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
    }

    // MARK: - ViewBuilders

    @ViewBuilder
    private var activityView: some View {
        let matches = action.matchingActivities(in: centers)
        if matches.count == 1, let match = matches.first {
            ActivityView(activity: match.activity, center: match.center)
        } else if matches.isEmpty {
            EmptyStateView(txt: "announcement-destination-unavailable")
        } else {
            List {
                ForEach(matches) { match in
                    Button {
                        navigationPath.append(.navigateToActivity(
                            activity: match.activity,
                            center: match.center
                        ))
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(match.activity.title)
                                .font(.headline)
                                .foregroundStyle(ColorsPalette.textPrimary)
                            Text(match.center.city)
                                .font(.subheadline)
                                .foregroundStyle(ColorsPalette.textSecondary)
                            Text(match.activity.schedule.joined(separator: "\n"))
                                .font(.footnote)
                                .foregroundStyle(ColorsPalette.textSecondary)
                        }
                        .padding(16)
                        .combinedAccessibility()
                    }
                    .buttonStyle(.plain)
                    .listRowConfiguration()
                }
            }
            .listConfiguration()
            .navigationTitle("announcement-select-activity")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
