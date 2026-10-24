//
//  Created by Michele Restuccia on 28/08/2026.
//

import SwiftUI
import RStudioKit
import AtegalCore

struct PushTopicView: View {

    @State
    var selectedPushTopics: Set<PushTopic> = []

    @State
    var presentCitiesSheet = false
    
    let pushManager: PushManager
    let announcementManager: AnnouncementManager

    init(pushManager: PushManager, announcementManager: AnnouncementManager) {
        self.pushManager = pushManager
        self.announcementManager = announcementManager
        _selectedPushTopics = State(initialValue: announcementManager.selectedPushTopics)
    }
    
    var body: some View {
        generalTopicView
        .sheet(isPresented: $presentCitiesSheet) {
            citiesSheet
        }
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var generalTopicView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("notification-general-title")
                .font(.headline.weight(.semibold))
                .foregroundStyle(ColorsPalette.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("notification-general-subtitle")
                .font(.body)
                .foregroundStyle(ColorsPalette.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("notification-general-centers-description")
                .font(.body)
                .foregroundStyle(ColorsPalette.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            citiesView
        }
        .padding(16)
        .ategalCornerBackground()
        .ategalCornerBorder()
        .combinedAccessibility()
    }

    @ViewBuilder
    private var citiesView: some View {
        Button {
            presentCitiesSheet = true
        } label: {
            Text("notification-cities-title")
                .font(.body.weight(.medium))
                .foregroundStyle(ColorsPalette.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .chevronOverlay()
                .contentRectangleShape()
                .combinedAccessibility()
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var citiesSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("notification-cities-subtitle")
                        .font(.body)
                        .foregroundStyle(ColorsPalette.textSecondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 4) {
                        ForEach(PushTopic.allCases.filter { $0 != .general } ) { topic in
                            let isSelected = selectedPushTopics.contains(topic)
                            HStack(spacing: 16) {
                                Text(topic.title)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(ColorsPalette.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                AsyncToggle(initialValue: isSelected) { isOn in
                                    if isOn {
                                        try await pushManager.subscribe(to: topic)
                                        selectedPushTopics.insert(topic)
                                    } else {
                                        try await pushManager.unsubscribe(from: topic)
                                        selectedPushTopics.remove(topic)
                                    }
                                    await announcementManager.setPushTopics(selectedPushTopics)
                                    Tracking.trackEvent(.notificationTopicChanged(
                                        topic: topic,
                                        enabled: isOn
                                    ))
                                    return isOn
                                }
                            }
                            .padding(16)
                            .ategalCornerBackground()
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .background(ColorsPalette.background)
            .navigationTitle("notification-cities-title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .presentationDetents([.medium])
            .toolbarWithDismissButton()
        }
        .tint(ColorsPalette.primary)
    }
}
