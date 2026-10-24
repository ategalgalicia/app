//
//  Created by Michele Restuccia on 20/10/26.
//

import SwiftUI
import Observation
import AtegalCore
import RStudioKit

struct AnnouncementActivityPickerView: View {
    
    @Environment(\.dismiss)
    var dismiss

    @Bindable
    var viewModel: AnnouncementActivityPickerViewModel

    let onSelect: (AnnouncementActivityPickerViewModel.Item) -> Void

    var body: some View {
        contentView
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("announcement-select-activity")
            .toolbarWithDismissButton()
            .topSafeAreaBar {
                AtegalSearchBarView(
                    $viewModel.searchText,
                    placeholder: "list-search-bar".localized
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                if viewModel.filteredItems.isEmpty {
                    EmptyStateView(txt: "announcement-activities-empty")
                } else {
                    ForEach(viewModel.filteredItems) { item in
                        Button {
                            onSelect(item)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.activity.title)
                                    .font(.headline)
                                    .foregroundStyle(ColorsPalette.textPrimary)

                                Text(item.center.city)
                                    .font(.subheadline)
                                    .foregroundStyle(ColorsPalette.textSecondary)

                                Text(item.activity.schedule.joined(separator: "\n"))
                                    .font(.footnote)
                                    .foregroundStyle(ColorsPalette.textSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .ategalCornerBackground()
                            .combinedAccessibility()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct AnnouncementActivityPickerAsyncView: View {
    let apiClient: GistAPIClient
    let topic: PushTopic
    let onSelect: (AnnouncementActivityPickerViewModel.Item) -> Void

    var body: some View {
        NavigationStack {
            AsyncView {
                await AnnouncementActivityPickerViewModel(
                    apiClient: apiClient,
                    topic: topic
                )
            } content: {
                AnnouncementActivityPickerView(
                    viewModel: $0,
                    onSelect: onSelect
                )
            }
            .background(ColorsPalette.background)
        }
        .tint(ColorsPalette.primary)
    }
}

@MainActor
@Observable
class AnnouncementActivityPickerViewModel {
    var searchText = ""
    let items: [Item]

    struct Item: Identifiable {
        let id: String
        let activity: Center.Category.Activity
        let center: Center
    }

    var filteredItems: [Item] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty ? items : items.filter {
            $0.activity.title.localizedCaseInsensitiveContains(query)
        }
    }

    init(apiClient: GistAPIClient, topic: PushTopic) async {
        let centers = await apiClient.fetchCenters()
        items = centers
            .filter { topic == .general || $0.city == topic.title }
            .flatMap { center in
                center.categories.flatMap { category in
                    category.activities.map { activity in
                        Item(
                            id: "\(center.id)|\(category.id)|\(activity.id)",
                            activity: activity,
                            center: center
                        )
                    }
                }
            }
            .sorted { $0.activity.title < $1.activity.title }
    }
}
