import SwiftUI
import RStudioKit

struct AnnouncementDetailView: View {
    @Binding
    var navigationPath: [InboxRoute]

    let item: InboxViewModel.Item

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(item.title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .multilineTextAlignment(.leading)
                    .accessibilityHeading(.h1)

                Text(item.topic.title)
                    .font(.subheadline)
                    .foregroundStyle(ColorsPalette.textSecondary)

                Text(item.publishedAt.formatted())
                    .font(.subheadline)
                    .foregroundStyle(ColorsPalette.textSecondary)

                Text(item.body)
                    .font(.body)
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .combinedAccessibility()
        }
        .background(ColorsPalette.background)
        .navigationTitle("inbox-title")
        .navigationBarTitleDisplayMode(.inline)
        .tint(ColorsPalette.primary)
        .toolbar(.hidden, for: .tabBar)
        .actionView {
            if let action = item.action {
                Button {
                    switch action {
                    case .activity(let title, let centerID):
                        navigationPath.append(.search(
                            .activitiesFilteredByText(title),
                            centerID: centerID
                        ))
                    case .calendar:
                        guard let date = action.calendarDate else { return }
                        navigationPath.append(.calendar(date))
                    }
                } label: {
                    Text(actionTitle)
                    .font(.headline)
                    .foregroundStyle(ColorsPalette.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .ategalCornerPrimaryBackground()
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var actionTitle: LocalizedStringKey {
        switch item.action {
        case .calendar:
            "announcement-action-calendar"
        default:
            "announcement-action-activity"
        }
    }
}
