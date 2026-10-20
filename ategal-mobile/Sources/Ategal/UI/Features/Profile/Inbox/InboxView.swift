//
//  Created by Michele Restuccia on 20/10/26.
//

import SwiftUI
import Observation
import AtegalCore
import RStudioKit

struct InboxView: View {
    
    @Bindable
    var viewModel: InboxViewModel

    let gistApiClient: GistAPIClient
    let onOpenAnnouncement: (Announcement.Action) -> Void

    @State
    var presentComposer = false

    var body: some View {
        Group {
            if viewModel.items.isEmpty {
                EmptyStateView(txt: "inbox-no-data")
            } else {
                List {
                    ForEach(viewModel.items) { item in
                        NavigationLink {
                            detailView(item)
                        } label: {
                            cell(item)
                        }
                        .listRowConfiguration()
                    }
                }
                .listConfiguration()
            }
        }
        .navigationTitle("inbox-title")
        .navigationBarTitleDisplayMode(.inline)
        .tint(ColorsPalette.primary)
        .toolbar { toolbarContent }
        .sheet(isPresented: $presentComposer) {
            AnnouncementComposeView(
                manager: viewModel.announcementManager,
                gistApiClient: gistApiClient
            )
        }
    }

    // MARK: - ToolbarContentBuilder

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if viewModel.shouldShowComposeButton {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presentComposer = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(Text("announcement-compose-title"))
            }
        }
    }

    // MARK: - ViewBuilders

    @ViewBuilder
    private func cell(_ item: InboxViewModel.Item) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.headline)
                .foregroundStyle(ColorsPalette.textPrimary)
                .accessibilityHeading(.h2)

            Text(item.topic.title)
                .font(.footnote)
                .foregroundStyle(ColorsPalette.textSecondary)

            Text(item.publishedAt.formatted())
                .font(.footnote)
                .foregroundStyle(ColorsPalette.textSecondary)

            Text(String(item.body.prefix(100)))
                .font(.body)
                .foregroundStyle(ColorsPalette.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .ategalCornerBackground()
        .combinedAccessibility()
    }
    
    @ViewBuilder
    private func detailView(_ item: InboxViewModel.Item) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(item.title)
                    .font(.title2.bold())
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .accessibilityHeading(.h1)

                Text(item.topic.title)
                    .font(.subheadline)
                    .foregroundStyle(ColorsPalette.textSecondary)

                Text(item.publishedAt.formatted())
                    .font(.footnote)
                    .foregroundStyle(ColorsPalette.textSecondary)

                Text(item.body)
                    .font(.body)
                    .foregroundStyle(ColorsPalette.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .combinedAccessibility()
        }
        .background(ColorsPalette.background)
        .navigationTitle("inbox-title")
        .navigationBarTitleDisplayMode(.inline)
        .tint(ColorsPalette.primary)
        .actionView {
            if let action = item.action {
                Button {
                    onOpenAnnouncement(action)
                } label: {
                    Group {
                        switch action {
                        case .activity:
                            Text("announcement-action-activity")
                        case .calendar:
                            Text("announcement-action-calendar")
                        }
                    }
                    .font(.headline)
                    .foregroundStyle(ColorsPalette.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .ategalCornerPrimaryBackground()
                }
            }
        }
    }
}

// MARK: - InboxAsyncView

struct InboxAsyncView: View {
    
    let announcementManager: AnnouncementManager
    let gistApiClient: GistAPIClient
    let onOpenAnnouncement: (Announcement.Action) -> Void
    
    var body: some View {
        AsyncView {
            try await InboxViewModel(announcementManager: announcementManager)
        } content: {
            InboxView(
                viewModel: $0,
                gistApiClient: gistApiClient,
                onOpenAnnouncement: onOpenAnnouncement
            )
        }
        .background(ColorsPalette.background)
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - InboxViewModel

@MainActor
@Observable
public class InboxViewModel {
    var items: [Item]
    struct Item: Identifiable {
        let id: String
        let title: String
        let body: String
        let topic: PushTopic
        let action: Announcement.Action?
        let publishedAt: Date
    }
    var shouldShowComposeButton: Bool
    
    let announcementManager: AnnouncementManager
    
    // SKIP @nobridge
    public init(announcementManager: AnnouncementManager) async throws {
        self.announcementManager = announcementManager
        shouldShowComposeButton = try await announcementManager.isAdministrator()
        let results = try await announcementManager.fetchAnnouncements()
        items = results.map { $0.viewModel }
    }
}

// MARK: - Extensions

private extension Announcement {
    
    var viewModel: InboxViewModel.Item {
        InboxViewModel.Item(
            id: id,
            title: title,
            body: body,
            topic: topic,
            action: action,
            publishedAt: publishedAt
        )
    }
}
