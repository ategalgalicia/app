//
//  Created by Michele Restuccia on 4/12/25.
//

import SwiftUI
import AtegalCore
import RStudioKit

struct SearchListView: View {
    
    private let source: Source
    enum Source: Hashable {
        case allActivities
        case activitiesFilteredByDay(Int)
        case activitiesFilteredByText(String)
        case resources
    }
    
    let onOpenActivity: (Center.Category.Activity, Center) -> Void
    
    @State
    var searchText: String = ""
    
    @State
    var selection: Selection? = nil
    struct Selection: Identifiable {
        var id: String { title }
        let title: String
        let centers: [Center]
    }
    
    private var activitiesByTitle: [String: [Center]] = [:]
    private var resourceItemByTitle: [String: Center.Category.Resource] = [:]
    
    private var items: [String] {
        let base: [String] = {
            switch source {
            case .allActivities, .activitiesFilteredByDay, .activitiesFilteredByText:
                activitiesByTitle.keys.sorted()
            case .resources:
                resourceItemByTitle.keys.sorted()
            }
        }()
        if searchText.isEmpty {
            return base
        } else {
            return base.filter {
                $0.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    init(
        source: Source,
        centers: [Center],
        onOpenActivity: @escaping (Center.Category.Activity, Center) -> Void
    ) {
        self.onOpenActivity = onOpenActivity
        self.source = source

        switch source {
        case .activitiesFilteredByText(let filterText):
            self._searchText = State(initialValue: filterText)
        default:
            self._searchText = State(initialValue: "")
        }

        switch source {
        case .allActivities:
            activitiesByTitle = centers.activitiesGroupedByTitle(for: nil)
        case .activitiesFilteredByDay(let filterDay):
            activitiesByTitle = centers.activitiesGroupedByTitle(for: filterDay)
        case .activitiesFilteredByText:
            activitiesByTitle = centers.activitiesGroupedByTitle(for: nil)
        case .resources:
            resourceItemByTitle = centers.resourcesItemGroupedByTitle()
        }
    }
    
    var body: some View {
        contentView
            .scrollDismissesKeyboard(.immediately)
            .background(ColorsPalette.background)
            .navigationTitle(source.title)
            .navigationBarTitleDisplayMode(.inline)
            .topSafeAreaBar {
                AtegalSearchBarView(
                    $searchText,
                    placeholder: "list-search-bar".localized
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .sheet(item: $selection) {
                switch source {
                case .allActivities, .activitiesFilteredByDay, .activitiesFilteredByText:
                    activityPicker(selection: $0)
                case .resources:
                    resourcePicker(selection: $0)
                }
            }
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                if items.isEmpty {
                    EmptyStateView(txt: source.emptytitle)
                } else {
                    ForEach(items, id: \.self) {
                        cell(for: $0)
                    }
                }
            }
            .padding([.horizontal, .bottom], 16)
        }
    }
    
    @ViewBuilder
    private func cell(for title: String) -> some View {
        let centers = activitiesByTitle[title] ?? []
        Button {
            cellAction(title, centers: centers)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .chevronOverlay()
                    .combinedAccessibility()
                    .accessibilityLabel(Text(title))
                
                if source.isActivity {
                    cities(centers)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .ategalCornerBackground()
        }
        .buttonStyle(.borderless)
        .ategalCornerBorder()
        .contentCapsuleShape()
    }
    
    @ViewBuilder
    private func cities(_ centers: [Center]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(centers) {
                    Text($0.city)
                        .font(.caption)
                        .foregroundStyle(ColorsPalette.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .cornerBackground(ColorsPalette.background)
                }
            }
        }
    }
    
    @ViewBuilder
    private func activityPicker(selection: Selection) -> some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("list-picker-activity-title")
                        .primaryTitle()
                    
                    VStack(spacing: 8) {
                        ForEach(selection.centers) { center in
                            Button {
                                navigateToActivity(title: selection.title, center: center)
                            } label: {
                                Text(center.city)
                                    .font(.body.weight(.regular))
                                    .foregroundStyle(ColorsPalette.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .chevronOverlay()
                                    .padding(16)
                                    .contentRectangleShape()
                            }
                            .buttonStyle(.plain)
                            .ategalCornerBackground()
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .background(ColorsPalette.background)
            .navigationTitle(selection.title)
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .presentationDetents([.medium])
            .toolbarWithDismissButton()
        }
        .tint(ColorsPalette.primary)
    }
    
    @ViewBuilder
    private func resourcePicker(selection: Selection) -> some View {
        if let item = resourceItemByTitle[selection.title] {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        Text(item.title)
                            .primaryTitle()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            if let description = item.description {
                                Text(description)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                            }
                            LinkView(
                                phoneNumbers: item.phone ?? [],
                                email: nil,
                                website: item.web,
                                address: item.address
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .background(ColorsPalette.background)
                .navigationBarTitleDisplayMode(.inline)
                .interactiveDismissDisabled()
                .presentationDetents([.medium])
                .toolbarWithDismissButton()
            }
            .tint(ColorsPalette.primary)
        }
    }
    
    // MARK: - Actions
    
    private func cellAction(_ title: String, centers: [Center]) {
        if source.isActivity, centers.count == 1, let center = centers.first {
            navigateToActivity(title: title, center: center)
        } else {
            selection = .init(title: title, centers: centers)
        }
    }
    
    private func navigateToActivity(title: String, center: Center) {
        guard let activity = center.activity(withTitle: title) else { return }
        onOpenActivity(activity, center)
        selection = nil
    }
}

// MARK: - Extensions

private extension SearchListView.Source {
    
    var title: String {
        switch self {
        case .allActivities, .activitiesFilteredByDay, .activitiesFilteredByText:
            "list-activity-title".localized
        case .resources: "list-resource-title".localized
        }
    }
    
    var emptytitle: String {
        switch self {
        case .allActivities, .activitiesFilteredByDay, .activitiesFilteredByText:
            "list-activity-no-data".localized
        case .resources: "list-resource-no-data".localized
        }
    }
    
    var isActivity: Bool {
        self != .resources
    }
}

private extension Array<Center> {
    
    func activitiesGroupedByTitle(for filterDay: Int?) -> [String: [Center]] {
        var result: [String: [Center]] = [:]
        for center in self {
            for category in center.categories {
                for activity in category.activities {
                    if let filterDay, !activity.weekday.contains(filterDay) { continue }
                    result[activity.title, default: []].append(center)
                }
            }
        }
        return result
    }
    
    func resourcesItemGroupedByTitle() -> [String: Center.Category.Resource] {
        var result: [String: Center.Category.Resource] = [:]
        for center in self {
            for category in center.categories {
                guard let resources = category.resources else { continue }
                for resource in resources {
                    result[resource.title] = resource
                }
            }
        }
        return result
    }
}

private extension Center {
    
    func activity(withTitle title: String) -> Category.Activity? {
        for category in categories {
            if let activity = category.activities.first(where: { $0.title == title }) {
                return activity
            }
        }
        return nil
    }
}
