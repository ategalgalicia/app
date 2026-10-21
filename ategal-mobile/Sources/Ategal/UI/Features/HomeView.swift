//
//  Created by Michele Restuccia on 3/12/25.
//

import SwiftUI
import AtegalCore
import RStudioKit

#if canImport(Darwin)

// MARK: - Previews

@available(iOS 18, *)
#Preview {
    @Previewable
    @State
    var navigationPath: [HomeRoute] = []
    
    NavigationStack {
        HomeView(
            navigationPath: $navigationPath,
            wpApiClient: .init(),
            centers: [],
            appVersion: "Versión 1.0.0"
        )
        .dynamicTypeSize(.large ... .accessibility5)
    }
}
#endif

// MARK: - HomeRoute

enum HomeRoute: Hashable {
    case navigateToCalendar
    case navigateToCityList
    case navigateToCategoryList(Center)
    case navigateToSearch(SearchListView.Source)
    case navigateToCategory(category: Center.Category, center: Center)
    case navigateToActivity(activity: Center.Category.Activity, center: Center)
}

// MARK: - HomeView

struct HomeView: View {
    
    @Binding
    var navigationPath: [HomeRoute]
    
    let wpApiClient: WPAPIClient
    let centers: [Center]
    let appVersion: String
    
    var body: some View {
        contentView
            .navigationDestination(for: HomeRoute.self) {
                destinationView(for: $0)
            }
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                questionView
                actionView
                partnerView
            }
            .padding(16)
        }
    }
    
    @ViewBuilder
    private var questionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("home-question-title")
                .font(.largeTitle.bold())
                .foregroundStyle(ColorsPalette.textPrimary)
                .multilineTextAlignment(.leading)
                .accessibilityAddTraits(.isHeader)
            
            Text("home-question-subtitle")
                .primaryTitle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var actionView: some View {
        VStack(alignment: .leading, spacing: 0) {
            itemView(
                title: "home-calendar-title",
                subtitle: "home-calendar-subtitle",
                image: "calendar",
                color: .red,
                onTap: {
                    navigationPath.append(.navigateToCalendar)
                    Tracking.trackEvent(.homeAction(destination: .calendar))
                }
            )
            Divider()
                .overlay(ColorsPalette.textSecondary.opacity(0.2))
                .padding(.horizontal, 16)
                .accessibilityHidden(true)
            itemView(
                title: "home-center-title",
                subtitle: "home-center-subtitle",
                image: "mappin.circle.fill",
                color: .mint,
                onTap: {
                    navigationPath.append(.navigateToCityList)
                    Tracking.trackEvent(.homeAction(destination: .centers))
                }
            )
            Divider()
                .overlay(ColorsPalette.textSecondary.opacity(0.2))
                .padding(.horizontal, 16)
                .accessibilityHidden(true)
            itemView(
                title: "home-activity-title",
                subtitle: "home-activity-subtitle",
                image: "list.bullet",
                color: .indigo,
                onTap: { navigationPath.append(.navigateToSearch(
                    .allActivities))
                    Tracking.trackEvent(.homeAction(destination: .activities))
                }
            )
            Divider()
                .overlay(ColorsPalette.textSecondary.opacity(0.2))
                .padding(.horizontal, 16)
                .accessibilityHidden(true)
            itemView(
                title: "home-resource-title",
                subtitle: "home-resource-subtitle",
                image: "info.circle",
                color: .orange,
                onTap: {
                    navigationPath.append(.navigateToSearch(.resources))
                    Tracking.trackEvent(.homeAction(destination: .resources))
                }
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .ategalCornerBackground()
    }
    
    @ViewBuilder
    private func itemView(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey,
        image: String,
        color: Color,
        onTap: @escaping ActionHandler
    ) -> some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: image)
                    .font(.largeTitle)
                    .foregroundStyle(color)
                    .padding(16)
                    .cornerBackground(color.opacity(0.15))
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundStyle(ColorsPalette.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(ColorsPalette.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .combinedAccessibility()
            }
            .contentRectangleShape()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .tint(ColorsPalette.textPrimary)
        .accessibility(label: title, hint: subtitle)
    }
    
    @ViewBuilder
    private var partnerView: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(ategal: "xunta-icon")
                .resizable()
                .scaledToFit()
                .frame(height: 30)
                .accessibilityHidden(true)
            
            Text(appVersion)
                .multilineTextAlignment(.center)
                .font(.caption2)
                .foregroundStyle(ColorsPalette.textSecondary.opacity(0.7))
                .combinedAccessibility()
                .frame(width: 95)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 24)
    }
    
    @ViewBuilder
    private func destinationView(for route: HomeRoute) -> some View {
        switch route {
        case .navigateToCalendar:
            CalendarAsyncView(
                onOpenDay: { day in
                    navigationPath.append(.navigateToSearch(.activitiesFilteredByDay(day)))
                },
                wpApiClient: wpApiClient,
                centers: centers
            )
        case .navigateToCityList:
            CityListView(
                onOpenCenter: { center in
                    navigationPath.append(.navigateToCategoryList(center))
                },
                centers: centers
            )
        case .navigateToSearch(let source):
            SearchListView(
                source: source,
                centers: centers,
                onOpenActivity: { activity, center in
                    navigationPath.append(.navigateToActivity(activity: activity, center: center))
                }
            )
        case .navigateToCategoryList(let center):
            CategoryListView(
                onOpenCategory: { category, center in
                    navigationPath.append(.navigateToCategory(category: category, center: center))
                },
                center: center
            )
        case .navigateToCategory(let category, let center):
            CategoryView(
                onOpenActivity: { activity, center in
                    navigationPath.append(.navigateToActivity(activity: activity, center: center))
                },
                category: category,
                center: center
            )
        case .navigateToActivity(let activity, let center):
            ActivityView(
                activity: activity,
                center: center
            )
        }
    }
}

// MARK: - HomeAsyncView

struct HomeAsyncView: View {
    
    @Binding
    var navigationPath: [HomeRoute]
    
    let wpApiClient: WPAPIClient
    let gistApiClient: GistAPIClient
    let appVersion: String
    
    init(
        navigationPath: Binding<[HomeRoute]>,
        wpApiClient: WPAPIClient,
        gistApiClient: GistAPIClient,
        appVersion: String
    ) {
        self._navigationPath = navigationPath
        self.wpApiClient = wpApiClient
        self.gistApiClient = gistApiClient
        self.appVersion = appVersion
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            AsyncView {
                await gistApiClient.fetchCenters()
            } content: {
                HomeView(
                    navigationPath: $navigationPath,
                    wpApiClient: wpApiClient,
                    centers: $0,
                    appVersion: appVersion
                )
            }
            .background(ColorsPalette.background)
            .navigationTitle("ategal-title")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(ColorsPalette.primary)
        .accessibilityHeading(.h1)
    }
}
