import SwiftUI
import AtegalCore
import RStudioKit

struct AnnouncementDestinationView: View {
    @Binding
    var navigationPath: [HomeRoute]

    let action: Announcement.Action
    let centers: [Center]
    let wpApiClient: WPAPIClient

    var body: some View {
        Group {
            switch action {
            case .activity:
                activityView
            case .calendar:
                if let date = action.calendarDate {
                    CalendarAsyncView(
                        navigationPath: $navigationPath,
                        wpApiClient: wpApiClient,
                        centers: centers,
                        initialDate: date
                    )
                } else {
                    EmptyStateView(txt: "announcement-destination-unavailable")
                }
            }
        }
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
                    NavigationLink(value: HomeRoute.navigateToActivity(
                        activity: match.activity,
                        center: match.center
                    )) {
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
                    .listRowConfiguration()
                }
            }
            .listConfiguration()
            .navigationTitle("announcement-select-activity")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
