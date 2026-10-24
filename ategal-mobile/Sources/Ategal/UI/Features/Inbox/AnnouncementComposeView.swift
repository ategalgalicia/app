//
//  Created by Michele Restuccia on 20/10/26.
//

import SwiftUI
import AtegalCore
import RStudioKit

struct AnnouncementComposeView: View {
    
    @Environment(\.dismiss)
    var dismiss
    
    @State
    var title = ""
    
    @State
    var message = ""
    
    @State
    var documentID = UUID().uuidString
    
    @State
    var topic: PushTopic = .general
    
    @State
    var actionKind: ActionKind = .none
    enum ActionKind: String, CaseIterable, Identifiable {
        case none, activity, calendar
        var id: String { rawValue }
    }
    
    @State
    var selectedActivity: SelectedActivity?
    struct SelectedActivity {
        let activity: Center.Category.Activity
        let center: Center
    }
    
    @State
    var calendarDate = Date()
    
    @State
    var navigationPath: [Route] = []
    enum Route: Hashable {
        case activityPicker
    }
    
    let manager: AnnouncementManager
    let centers: [Center]
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            contentView
                .foregroundStyle(ColorsPalette.textPrimary)
                .navigationTitle("announcement-compose-title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarWithDismissButton()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .activityPicker:
                        SearchListView(
                            source: .allActivities,
                            centers: activityCenters,
                            onOpenActivity: { activity, center in
                                selectedActivity = .init(
                                    activity: activity,
                                    center: center
                                )
                                navigationPath.removeLast()
                            }
                        )
                    }
                }
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
        .onChange(of: topic) { _, _ in
            selectedActivity = nil
        }
    }
    
    // MARK: - ViewBuilder
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("announcement-topic-label".localized)
                    .font(.headline)
                
                Picker("announcement-topic-label".localized, selection: $topic) {
                    ForEach(PushTopic.allCases) { topic in
                        Text(topic.title).tag(topic)
                    }
                }
                .ategalCornerBackground()
                
                Text("announcement-title-label".localized)
                    .font(.headline)
                
                TextField("announcement-title-label".localized, text: $title)
                    .padding(16)
                    .ategalCornerBackground()
                
                Text("announcement-body-label".localized)
                    .font(.headline)
                
                TextEditor(text: $message)
                    .frame(minHeight: 180)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .ategalCornerBackground()
                    .accessibilityLabel(Text("announcement-body-label"))
                
                actionFields
                
                Text("announcement-limits".localized)
                    .font(.footnote)
                    .foregroundStyle(ColorsPalette.textSecondary)
            }
            .padding(16)
        }
        .actionView {
            AsyncButton {
                let request = AnnouncementRequest(
                    id: documentID,
                    title: title,
                    body: message,
                    topic: topic,
                    action: announcementAction
                )
                try await manager.publish(request)
                dismiss()
            } label: {
                Text("announcement-publish".localized)
                    .font(.headline)
                    .foregroundStyle(ColorsPalette.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .ategalCornerPrimaryBackground()
            }
            .disabled(!isValid)
            .opacity(isValid ? 1 : 0.5)
        }
    }
    
    @ViewBuilder
    private var actionFields: some View {
        Text("announcement-action-label".localized)
            .font(.headline)
        
        Picker("announcement-action-label".localized, selection: $actionKind) {
            ForEach(ActionKind.allCases) { kind in
                Text(kind.title).tag(kind)
            }
        }
        .ategalCornerBackground()
        
        switch actionKind {
        case .none:
            EmptyView()
        case .activity:
            Button {
                navigationPath.append(.activityPicker)
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("announcement-select-activity".localized)
                        .font(.headline)
                    
                    if let selectedActivity {
                        Text(selectedActivity.activity.title)
                        Text(selectedActivity.center.city)
                            .font(.subheadline)
                        Text(selectedActivity.activity.schedule.joined(separator: "\n"))
                            .font(.footnote)
                    }
                }
                .foregroundStyle(ColorsPalette.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .chevronOverlay()
                .padding(16)
                .ategalCornerBackground()
                .combinedAccessibility()
            }
            .buttonStyle(.plain)
        case .calendar:
            DatePicker(
                "announcement-calendar-day".localized,
                selection: $calendarDate,
                displayedComponents: .date
            )
            #if canImport(Darwin)
            .environment(\.calendar, Calendar(identifier: .gregorian))
            #endif
            .padding(16)
            .ategalCornerBackground()
        }
    }
    
    private var activityCenters: [Center] {
        topic == .general
            ? centers
            : centers.filter { $0.city == topic.title }
    }
    
    private var isValid: Bool {
        AnnouncementRequest.areFieldsValid(title: title, body: message)
        && (actionKind != .activity || selectedActivity != nil)
    }
    
    private var announcementAction: Announcement.Action? {
        switch actionKind {
        case .none:
            return nil
        case .activity:
            guard let selectedActivity else { return nil }
            return .activity(
                title: selectedActivity.activity.title,
                centerID: selectedActivity.center.id
            )
        case .calendar:
            return .calendar(day: Announcement.Action.calendarDay(from: calendarDate))
        }
    }
}

// MARK: - Extensions

private extension AnnouncementComposeView.ActionKind {
    
    var title: String {
        switch self {
        case .none: "announcement-action-none".localized
        case .activity: "announcement-action-activity".localized
        case .calendar: "announcement-action-calendar".localized
        }
    }
}
