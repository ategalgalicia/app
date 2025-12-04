//
//  Created by Michele Restuccia on 4/12/25.
//

import SwiftUI
import AtegalCore

struct ActivitySearchView: View {
    
    @Bindable
    var dataSource: HomeDataSource
    
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
    
    private var items: [String] {
        let base = dataSource.sortedActivities
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
            .navigationTitle("activity-search")
            .navigationBarTitleDisplayMode(.inline)
            .platformSearchable(text: $searchText, prompt: "activity-search-bar")
            .sheet(item: $selection) {
                picker(selection: $0)
            }
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { title in
                    cell(title, centers: dataSource.centers(for: title))
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    private func cell(_ title: String, centers: [Center]) -> some View {
        Button {
            if centers.count == 1, let center = centers.first {
                navigateToActivity(title: title, center: center)
            } else {
                selection = .init(title: title, centers: centers)
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.body.weight(.regular))
                    .foregroundStyle(ColorsPalette.textSecondary)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                
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
                    .padding(16)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentRectangleShape()
        .cornerBackground()
    }
    
    @ViewBuilder
    private func picker(selection: Selection) -> some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("activity-search-picker-title")
                        .font(.body)
                        .multilineTextAlignment(.leading)
                    
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
    
    // MARK: Actions
    
    private func navigateToActivity(title: String, center: Center) {
        let data = dataSource.activityWithCategory(forActivityTitle: title, in: center)
        guard let data else { return }
        dataSource.centerSelected = center
        dataSource.categorySelected = data.category
        dataSource.activitySelected = data.activity
        navigationPath.append(.navigateToActivity)
        selection = nil
    }
}

// MARK: Extensions

private extension HomeDataSource {
    
    var sortedActivities: [String] {
        activitiesByTitle.keys.sorted()
    }
    
    func centers(for title: String) -> [Center] {
        activitiesByTitle[title] ?? []
    }
    
    func activityWithCategory(forActivityTitle title: String, in center: Center)
    -> (category: Center.Category, activity: Center.Category.Activity)? {
        
        for category in center.categories {
            if let activity = category.activities.first(where: { $0.title == title }) {
                return (category, activity)
            }
        }
        return nil
    }
}
