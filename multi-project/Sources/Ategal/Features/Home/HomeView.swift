//
//  Created by Michele Restuccia on 3/12/25.
//

import SwiftUI
import AtegalCore

#if canImport(Darwin)

// MARK: Previews

@available(iOS 18, *)
#Preview {
    @Previewable
    @State
    var navigationPath: [HomeRoute] = []
    
    NavigationStack {
        HomeView(
            navigationPath: $navigationPath,
            apiClient: .init(),
            centers: [],
            appVersion: "Versión 1.0.0"
        )
        .dynamicTypeSize(.large ... .accessibility5)
    }
}
#endif

// MARK: HomeView

struct HomeView: View {
    
    @Binding
    var navigationPath: [HomeRoute]
    
    let apiClient: AtegalAPIClient
    let centers: [Center]
    let appVersion: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                questionView
                actionView
                partnerView
            }
            .padding(.horizontal, 16)
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
        .navigationTitle("ategal-title")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: HomeRoute.self) {
            switch $0 {
            case .navigateToCalendar:
                CalendarAsyncView(
                    apiClient: apiClient,
                    navigationPath: $navigationPath
                )
            case .navigateToCityList:
                CityListView(
                    navigationPath: $navigationPath,
                    centers: centers
                )
            case .navigateToCategoryList(let center):
                CategoryListView(
                    navigationPath: $navigationPath,
                    center: center
                )
            case .navigateToCategory(let category, let center):
                CategoryView(
                    navigationPath: $navigationPath,
                    category: category,
                    center: center
                )
            case .navigateToActivity(let activity, let center):
                ActivityView(
                    activity: activity,
                    center: center
                )
                
            case .navigateToSearch(let source):
                ListSearchView(
                    source: source,
                    centers: centers,
                    navigationPath: $navigationPath
                )
            }
        }
    }
    
    // MARK: ViewBuilders
    
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
        .padding(16)
        .cornerBackground()
    }
    
    @ViewBuilder
    private var actionView: some View {
        VStack(alignment: .leading, spacing: 0) {
            itemView(
                title: "home-calendar-title",
                subtitle: "home-calendar-subtitle",
                image: "calendar",
                color: .red,
                onTap: { navigationPath.append(.navigateToCalendar) }
            )
            itemView(
                title: "home-center-title",
                subtitle: "home-center-subtitle",
                image: "mappin.circle.fill",
                color: .mint,
                onTap: { navigationPath.append(.navigateToCityList) }
            )
            itemView(
                title: "home-activity-title",
                subtitle: "home-activity-subtitle",
                image: "list.bullet",
                color: .indigo,
                onTap: { navigationPath.append(.navigateToSearch(
                    .activities(filterDay: nil)))
                }
            )
            itemView(
                title: "home-resource-title",
                subtitle: "home-resource-subtitle",
                image: "info.circle",
                color: .orange,
                onTap: { navigationPath.append(.navigateToSearch(.resources)) }
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerBackground()
    }
    
    @ViewBuilder
    private func itemView(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey,
        image: String,
        color: Color,
        onTap: VoidHandler?
    ) -> some View {
        Button {
            onTap?()
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
            Image("xunta-icon", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(height: 30)
                .accessibilityHidden(true)
            
            Text(appVersion)
                .multilineTextAlignment(.center)
                .font(.caption2)
                .foregroundStyle(ColorsPalette.textSecondary.opacity(0.2))
                .combinedAccessibility()
                .frame(width: 90)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 24)
    }
}

// MARK: WhoWeAreAsyncView

struct HomeAsyncView: View {
    
    @Binding
    var navigationPath: [HomeRoute]
    
    let apiClient: AtegalAPIClient
    let appVersion: String
    
    init(
        navigationPath: Binding<[HomeRoute]>,
        apiClient: AtegalAPIClient,
        appVersion: String
    ) {
        self._navigationPath = navigationPath
        self.apiClient = apiClient
        self.appVersion = appVersion
    }
    
    var body: some View {
        AsyncView {
            await apiClient.fetchCenters()
        } content: {
            HomeView(
                navigationPath: $navigationPath,
                apiClient: apiClient,
                centers: $0,
                appVersion: appVersion
            )
        }
    }
}


// MARK: HomeRoute

enum HomeRoute: Hashable {
    case navigateToCalendar
    case navigateToCityList
    case navigateToCategoryList(Center)
    case navigateToCategory(category: Center.Category, center: Center)
    case navigateToActivity(activity: Center.Category.Activity, center: Center)
    case navigateToSearch(SearchSource)
}
