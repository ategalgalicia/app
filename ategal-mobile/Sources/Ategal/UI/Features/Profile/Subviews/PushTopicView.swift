//
//  Created by Michele Restuccia on 28/08/2026.
//

import SwiftUI
import RStudioKit
import AtegalCore

struct PushTopicView: View {

    @UserDefaultsBacked(key: "push-selected-city-topics")
    var storedPushTopics: Set<PushTopic> = []

    @State
    var selectedPushTopics: Set<PushTopic> = []

    @State
    var presentCitiesSheet = false
    
    let pushManager: PushManager

    init(pushManager: PushManager) {
        self.pushManager = pushManager
        _selectedPushTopics = State(initialValue: storedPushTopics)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            generalTopicView
            citiesView
        }
        .sheet(isPresented: $presentCitiesSheet) {
            citiesSheet
        }
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var generalTopicView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("notification-general-title")
                    .font(.headline)
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("notification-general-subtitle")
                    .font(.subheadline)
                    .foregroundStyle(ColorsPalette.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            CheckmarkView(isSelected: true, primaryColor: .gray)
        }
        .padding(16)
        .ategalCornerBackground()
        .combinedAccessibility()
    }

    @ViewBuilder
    private var citiesView: some View {
        Button {
            presentCitiesSheet = true
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("notification-cities-title")
                        .font(.headline)
                        .foregroundStyle(ColorsPalette.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("notification-cities-subtitle")
                        .font(.subheadline)
                        .foregroundStyle(ColorsPalette.textSecondary)
                        .padding(.trailing, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .chevronOverlay()
            .padding(16)
            .ategalCornerBackground()
            .combinedAccessibility()
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var citiesSheet: some View {
        PresentationSheetContainer(
            title: "notification-cities-title".localized
        ) {
            Text("notification-cities-subtitle")
                .font(.body)
                .foregroundStyle(ColorsPalette.textSecondary)

            VStack(spacing: 4) {
                ForEach(PushTopic.allCases.filter { $0 != .general } ) { topic in
                    let isSelected = selectedPushTopics.contains(topic)
                    HStack(spacing: 16) {
                        Text(topic.title)
                            .font(.headline)
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
                            storedPushTopics = selectedPushTopics
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
    }

}

// MARK: - Extensions

private extension PushTopic {

    var title: String {
        switch self {
        case .general: "General"
        case .santiago: "Santiago de Compostela"
        case .acoruna: "A Coruña"
        case .ferrol: "Ferrol"
        case .lalin: "Lalín"
        case .monterroso: "Monterroso"
        case .ourense: "Ourense"
        case .padron: "Padrón"
        case .vigo: "Vigo"
        }
    }
}
