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

    @State
    var selectedActivity: AnnouncementActivityPickerViewModel.Item?

    @State
    var calendarDate = Date()

    @State
    var presentActivityPicker = false

    enum ActionKind: String, CaseIterable, Identifiable {
        case none, activity, calendar
        var id: String { rawValue }

        var title: LocalizedStringKey {
            switch self {
            case .none: "announcement-action-none"
            case .activity: "announcement-action-activity"
            case .calendar: "announcement-action-calendar"
            }
        }
    }
    
    let manager: AnnouncementManager
    let gistApiClient: GistAPIClient
    
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

    var body: some View {
        NavigationStack {
            contentView
            .foregroundStyle(ColorsPalette.textPrimary)
            .background(ColorsPalette.background)
            .navigationTitle("announcement-compose-title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarWithDismissButton()
        }
        .tint(ColorsPalette.primary)
        .onChange(of: topic) { _, _ in
            selectedActivity = nil
        }
        .sheet(isPresented: $presentActivityPicker) {
            AnnouncementActivityPickerAsyncView(
                apiClient: gistApiClient,
                topic: topic
            ) {
                selectedActivity = $0
            }
        }
    }
    
    // MARK: - ViewBuilder
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("announcement-topic-label")
                    .font(.headline)

                Picker("announcement-topic-label", selection: $topic) {
                    ForEach(PushTopic.allCases) { topic in
                        Text(topic.title).tag(topic)
                    }
                }
                .ategalCornerBackground()

                Text("announcement-title-label")
                    .font(.headline)
                
                TextField("announcement-title-label", text: $title)
                    .padding(16)
                    .ategalCornerBackground()

                Text("announcement-body-label")
                    .font(.headline)
                
                TextEditor(text: $message)
                    .frame(minHeight: 180)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .ategalCornerBackground()
                    .accessibilityLabel(Text("announcement-body-label"))

                actionFields

                Text("announcement-limits")
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
                Text("announcement-publish")
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
        Text("announcement-action-label")
            .font(.headline)

        Picker("announcement-action-label", selection: $actionKind) {
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
                presentActivityPicker = true
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("announcement-select-activity")
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
                "announcement-calendar-day",
                selection: $calendarDate,
                displayedComponents: .date
            )
            #if !os(Android)
            .environment(\.calendar, Calendar(identifier: .gregorian))
            #endif
            .padding(16)
            .ategalCornerBackground()
        }
    }
}
