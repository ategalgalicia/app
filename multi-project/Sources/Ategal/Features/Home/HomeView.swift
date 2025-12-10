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
            apiClient: .init()
        )
        .dynamicTypeSize(.large ... .accessibility5)
    }
}
#endif

// MARK: HomeRoute

enum HomeRoute: Hashable {
    case navigateToCalendar
    case navigateToCityList
    case navigateToCategoryList
    case navigateToCategory
    case navigateToActivity
    case navigateToSearch(SearchSource)
}

// MARK: HomeView

struct HomeView: View {
    
    @Binding
    var navigationPath: [HomeRoute]
    
    @State
    var dataSource: HomeDataSource
        
    init(
        navigationPath: Binding<[HomeRoute]>,
        apiClient: AtegalAPIClient
    ) {
        self._navigationPath = navigationPath
        self.dataSource = HomeDataSource(apiClient: apiClient)
    }
    
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
                CalendarAsyncView(apiClient: dataSource.apiClient)
            case .navigateToCityList:
                CityListView(
                    dataSource: dataSource,
                    navigationPath: $navigationPath
                )
            case .navigateToCategoryList:
                CategoryListView(
                    dataSource: dataSource,
                    navigationPath: $navigationPath
                )
            case .navigateToCategory:
                CategoryView(
                    dataSource: dataSource,
                    navigationPath: $navigationPath
                )
            case .navigateToActivity:
                ActivityView(dataSource: dataSource)
                
            case .navigateToSearch(let source):
                ListSearchView(
                    source: source,
                    dataSource: dataSource,
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
                .font(.title3)
                .foregroundStyle(ColorsPalette.textSecondary)
                .multilineTextAlignment(.leading)
                .lineSpacing()
                .combinedAccessibility()
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
                onTap: { navigationPath.append(.navigateToSearch(.activities)) }
            )
            itemView(
                title: "home-resource-title",
                subtitle: "home-resource-subtitle",
                image: "list.bullet",
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
                    .font(.system(size: 26, weight: .semibold))
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
        VStack(alignment: .center, spacing: 0) {
            Image("xunta-icon", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .accessibilityHidden(true)
            
            Text("home-partner-message")
                .multilineTextAlignment(.center)
                .font(.caption2)
                .foregroundStyle(ColorsPalette.textSecondary)
                .combinedAccessibility()
                .frame(width: 90)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 24)
    }
}

@Observable
@MainActor
class HomeDataSource {
    
    @ObservationIgnored
    let apiClient: AtegalAPIClient
    
    @ObservationIgnored
    let centers: [Center]
    
    @ObservationIgnored
    var activitiesByTitle: [String: [Center]] = [:]
    
    @ObservationIgnored
    var resourceByTitle: [String: [Center]] = [:]
    
    var centerSelected: Center? = nil
    var categorySelected: Center.Category? = nil
    var activitySelected: Center.Category.Activity? = nil
        
    init(apiClient: AtegalAPIClient) {
        self.apiClient = apiClient
        self.centers = apiClient.fetchCenters()
        
        centers.forEach { center in
            center.categories.forEach { category in
                category.activities.forEach { activity in
                    activitiesByTitle[activity.title, default: []].append(center)
                }
                category.resources?.forEach { resource in
                    resourceByTitle[resource.title, default: []].append(center)
                }
            }
        }
    }
}
