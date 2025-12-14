//
//  Created by Michele Restuccia on 4/12/25.
//

import SwiftUI
import AtegalCore

enum SearchSource: Hashable {
    case activities(filterDay: Int?)
    case resources
}

struct ListSearchView: View {
    
    let source: SearchSource
    let centers: [Center]
    var activitiesByTitle: [String: [Center]] = [:]
    var resourceByTitle: [String: [Center]] = [:]
    
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
    
    init(
        source: SearchSource,
        centers: [Center],
        navigationPath: Binding<[HomeRoute]>
    ) {
        self.source = source
        self.centers = centers
        self._navigationPath = navigationPath
        
        switch source {
        case .activities(let filterDay):
            centers.forEach { center in
                center.categories.forEach { category in
                    category.activities.forEach { activity in
                        if let filterDay {
                            if activity.weekday.contains(filterDay) {
                                activitiesByTitle[activity.title, default: []].append(center)
                            }
                        } else {
                            activitiesByTitle[activity.title, default: []].append(center)
                        }
                    }
                }
            }
        case .resources:
            centers.forEach { center in
                center.categories.forEach { category in
                    category.resources?.forEach { resource in
                        resourceByTitle[resource.title, default: []].append(center)
                    }
                }
            }
        }
    }
    
    private var items: [String] {
        let base: [String] = {
            switch source {
            case .activities: sortedActivities
            case .resources: sortedResources
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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) {
                    cell(for: $0)
                }
            }
            .padding(.horizontal, 16)
        }
        .overlay(alignment: .center) {
            if items.isEmpty {
                EmptyView(txt: source.emptytitle)
            }
        }
    }
    
    @ViewBuilder
    private func cell(for title: String) -> some View {
        let centers = centers(for: title)
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
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
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
                                        .multilineTextAlignment(.leading)

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
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle(selection.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarWithDismissButton()
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
        .presentationDetents([.medium])
    }
    
    @ViewBuilder
    private func resourcePicker(selection: Selection) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let item = resource(for: selection.title) {
                        
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
                    
                    Spacer()
                }
                .padding(16)
            }
            .toolbarWithDismissButton()
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
        .presentationDetents([.medium])
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
        guard let activity = activity(for: title, in: center) else {
            return
        }
        navigationPath.append(.navigateToActivity(
            activity: activity, center: center
        ))
        selection = nil
    }
}

// MARK: Extensions

private extension ListSearchView {
    
    var sortedActivities: [String] {
        activitiesByTitle.keys.sorted()
    }
    var sortedResources: [String] {
        resourceByTitle.keys.sorted()
    }
    
    func centers(for title: String) -> [Center] {
        activitiesByTitle[title] ?? []
    }
    
    func activity(for title: String, in center: Center)
    -> Center.Category.Activity? {
        for category in center.categories {
            if let activity = category.activities.first(where: { $0.title == title }) {
                return activity
            }
        }
        return nil
    }
    
    func resource(for title: String)
    -> Center.Category.Resource? {
        for center in centers {
            for category in center.categories {
                if let resource = category.resources?.first(where: { $0.title == title }) {
                    return resource
                }
            }
        }
        return nil
    }
}
private extension SearchSource {
    
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

