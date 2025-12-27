//
//  Created by Michele Restuccia on 4/12/25.
//

import SwiftUI
import AtegalCore

struct SearchListView: View {
    
    private let source: Source
    enum Source: Hashable {
        case activities(filterDay: Int?)
        case resources
    }
    
    @Binding
    var navigationPath: [HomeRoute]
    
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
            case .activities:
                return activitiesByTitle.keys.sorted()
            case .resources:
                return resourceItemByTitle.keys.sorted()
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
        navigationPath: Binding<[HomeRoute]>,
        source: Source,
        centers: [Center]
    ) {
        self._navigationPath = navigationPath
        self.source = source
        switch source {
        case .activities(let filterDay):
            activitiesByTitle = centers.activitiesGroupedByTitle(for: filterDay)
        case .resources:
            resourceItemByTitle = centers.resourcesItemGroupedByTitle()
        }
    }
    
    var body: some View {
        contentView
            .background(ColorsPalette.background)
            .navigationTitle(source.title)
            .navigationBarTitleDisplayMode(.inline)
            .platformSearchable(text: $searchText, prompt: "list-search-bar")
            .sheet(item: $selection) {
                switch source {
                case .activities:
                    activityPicker(selection: $0)
                case .resources:
                    resourcePicker(selection: $0)
                }
            }
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        if items.isEmpty {
            EmptyStateView(txt: source.emptytitle)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(items, id: \.self) {
                        cell(for: $0)
                    }
                }
                .padding(16)
            }
        }
    }
    
    @ViewBuilder
    private func cell(for title: String) -> some View {
        let centers = activitiesByTitle[title] ?? []
        Button {
            cellAction(title, centers: centers)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 16) {
                    Text(title)
                        .font(.body.weight(.regular))
                        .foregroundStyle(ColorsPalette.textSecondary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(ColorsPalette.primary)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .combinedAccessibility()
                .accessibilityLabel(Text(title))
                
                if source.isActivity {
                    cities(centers)
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentRectangleShape()
        .cornerBackground()
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
        PresentationSheetContainer(title: selection.title) {
            Text("list-picker-activity-title")
                .primaryTitle()
            
            VStack(spacing: 8) {
                ForEach(selection.centers) { center in
                    Button {
                        navigateToActivity(title: selection.title, center: center)
                    } label: {
                        HStack(spacing: 16) {
                            Text(center.city)
                                .font(.body.weight(.regular))
                                .foregroundStyle(ColorsPalette.textSecondary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(ColorsPalette.primary)
                                .accessibilityHidden(true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .contentRectangleShape()
                    }
                    .buttonStyle(.plain)
                    .cornerBackground()
                }
            }
        }
    }
    
    @ViewBuilder
    private func resourcePicker(selection: Selection) -> some View {
        if let item = resourceItemByTitle[selection.title] {
            PresentationSheetContainer() {
                Text(item.title)
                    .primaryTitle()
                
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
                .padding(16)
                .cornerBackground()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    // MARK: Actions
    
    private func cellAction(_ title: String, centers: [Center]) {
        if source.isActivity, centers.count == 1, let center = centers.first {
            navigateToActivity(title: title, center: center)
        } else {
            selection = .init(title: title, centers: centers)
        }
    }
    
    private func navigateToActivity(title: String, center: Center) {
        guard let activity = center.activity(withTitle: title) else { return }
        navigationPath.append(.navigateToActivity(activity: activity, center: center))
        selection = nil
    }
}

// MARK: Extensions

private extension SearchListView.Source {
    
    var title: LocalizedStringKey {
        switch self {
        case .activities: "list-activity-title"
        case .resources: "list-resource-title"
        }
    }
    
    var emptytitle: LocalizedStringKey {
        switch self {
        case .activities: "list-activity-no-data"
        case .resources: "list-resource-no-data"
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
