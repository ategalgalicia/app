//
//  Created by Michele Restuccia on 20/10/26.
//

import SwiftUI
import RStudioKit

struct AnnouncementDetailView: View {
    @Binding
    var navigationPath: [InboxRoute]

    let item: InboxViewModel.Item

    var body: some View {
        contentView
            .background(ColorsPalette.background)
            .navigationTitle("inbox-title")
            .navigationBarTitleDisplayMode(.inline)
            .tint(ColorsPalette.primary)
            .toolbar(.hidden, for: .tabBar)
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(item.title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .multilineTextAlignment(.leading)
                    .accessibilityHeading(.h1)
                
                Text(item.topic.title)
                    .font(.caption)
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .cornerBackground(ColorsPalette.backgroundSecondary, radius: 100)
                
                Text(item.publishedAt.formatted())
                    .font(.subheadline)
                    .foregroundStyle(ColorsPalette.textSecondary)
                
                Text(item.body)
                    .font(.body)
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                
                actionView
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .combinedAccessibility()
        }
    }
    
    @ViewBuilder
    private var actionView: some View {
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
                Text(actionTitle.localized)
                    .font(.body.weight(.medium))
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .chevronOverlay()
                    .padding(16)
                    .ategalCornerBackground()
                    .combinedAccessibility()
            }
            .buttonStyle(.plain)
        }
    }

    private var actionTitle: String {
        switch item.action {
        case .calendar:
            "announcement-action-calendar"
        default:
            "announcement-action-activity"
        }
    }
}
