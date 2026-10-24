//
//  Created by Michele Restuccia on 20/10/26.
//

import SwiftUI
import Observation
import AtegalCore
import RStudioKit

#if canImport(Darwin)

// MARK: - Previews

@available(iOS 18, *)
#Preview {
    InboxAsyncView(
        navigationPath: .constant([]),
        announcementManager: .init(),
        gistApiClient: .init(),
        wpApiClient: .init()
    )
}
#endif

// MARK: - InboxRoute

enum InboxRoute: Hashable {
    case detail(InboxViewModel.Item)
    case calendar(Date)
    case search(SearchListView.Source, centerID: String?)
    case navigateToActivity(activity: Center.Category.Activity, center: Center)
}

// MARK: - InboxView

struct InboxView: View {
    
    @Bindable
    var viewModel: InboxViewModel

    let wpApiClient: WPAPIClient

    @Binding
    var navigationPath: [InboxRoute]

    @State
    var presentComposer = false

    var body: some View {
        Group {
            if viewModel.items.isEmpty {
                EmptyStateView(txt: "inbox-no-data")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.items) { item in
                            Button {
                                navigationPath.append(.detail(item))
                            } label: {
                                cell(item)
                            }
                            .buttonStyle(.plain)
                            .ategalCornerBorder()
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .navigationTitle("inbox-title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .navigationDestination(for: InboxRoute.self) {
            destinationView($0)
        }
        .sheet(isPresented: $presentComposer) {
            AnnouncementComposeView(
                manager: viewModel.announcementManager,
                centers: viewModel.centers
            )
        }
    }

    // MARK: - Navigation

    @ViewBuilder
    private func destinationView(_ route: InboxRoute) -> some View {
        switch route {
        case .detail(let item):
            AnnouncementDetailView(
                navigationPath: $navigationPath,
                item: item,
            )
            .onAppear {
                viewModel.announcementManager.markRead(item.id)
            }
        case .navigateToActivity(let activity, let center):
            ActivityView(activity: activity, center: center)
        case .calendar(let date):
            CalendarAsyncView(
                onOpenDay: { day in
                    navigationPath.append(.search(.activitiesFilteredByDay(day), centerID: nil))
                },
                wpApiClient: wpApiClient,
                centers: viewModel.centers,
                initialDate: date
            )
        case .search(let source, let centerID):
            SearchListView(
                source: source,
                centers: viewModel.centers.filter { centerID == nil || $0.id == centerID },
                onOpenActivity: { activity, center in
                    navigationPath.append(.navigateToActivity(activity: activity, center: center))
                }
            )
        }
    }

    // MARK: - ViewBuilders

    @ViewBuilder
    private func cell(_ item: InboxViewModel.Item) -> some View {
        let isUnread = viewModel.announcementManager.isUnread(item.id)
        HStack(alignment: .center, spacing: 8) {
            Circle()
                .fill(ColorsPalette.primary)
                .frame(width: 10, height: 10)
                .opacity(isUnread ? 1 : 0)
                .accessibilityLabel(Text("inbox-unread"))
                .accessibilityHidden(!isUnread)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(item.topic.title)
                        .font(.caption)
                        .foregroundStyle(ColorsPalette.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .cornerBackground(ColorsPalette.backgroundSecondary, radius: 100)

                    Text(item.publishedAt.formatted(.dateTime.day().month(.abbreviated)))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .font(.subheadline)
                .foregroundStyle(ColorsPalette.textSecondary)

                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .accessibilityHeading(.h2)

                item.body.truncatedText()
                    .font(.subheadline)
                    .foregroundStyle(ColorsPalette.textSecondary)
            }
        }
        .multilineTextAlignment(.leading)
        .padding(.trailing, 32)
        .frame(maxWidth: .infinity, alignment: .leading)
        .chevronOverlay()
        .padding(.leading, 8)
        .padding([.trailing, .vertical], 16)
        .ategalCornerBackground()
        .combinedAccessibility()
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
}

// MARK: - InboxAsyncView

struct InboxAsyncView: View {

    @Binding
    var navigationPath: [InboxRoute]
    
    let announcementManager: AnnouncementManager
    let gistApiClient: GistAPIClient
    let wpApiClient: WPAPIClient

    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            AsyncView {
                try await InboxViewModel(
                    announcementManager: announcementManager,
                    gistApiClient: gistApiClient
                )
            } content: {
                InboxView(
                    viewModel: $0,
                    wpApiClient: wpApiClient,
                    navigationPath: $navigationPath
                )
            }
            .background(ColorsPalette.background)
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .accessibilityHeading(.h1)
    }
}

// MARK: - InboxViewModel

@MainActor
@Observable
public class InboxViewModel {
    var items: [Item] {
        announcementManager.announcements.map { $0.viewModel }
    }
    struct Item: Identifiable, Hashable {
        let id: String
        let title: String
        let body: String
        let topic: PushTopic
        let action: Announcement.Action?
        let publishedAt: Date
    }
    var shouldShowComposeButton: Bool
    
    let announcementManager: AnnouncementManager
    let centers: [Center]
    
    // SKIP @nobridge
    public init(
        announcementManager: AnnouncementManager,
        gistApiClient: GistAPIClient
    ) async throws {
        self.announcementManager = announcementManager
        shouldShowComposeButton = try await announcementManager.isAdministrator()
        _ = try await announcementManager.fetchAnnouncements()
        centers = await gistApiClient.fetchCenters()
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

private extension String {
    
    @ViewBuilder
    func truncatedText() -> some View {
        #if os(Android)
        Text(count > 100 ? String(prefix(100)) + "..." : self)
        #else
        Text(self)
            .lineLimit(2)
            .truncationMode(.tail)
        #endif
    }
}
