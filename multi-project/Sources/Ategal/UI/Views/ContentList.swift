//
//  Created by Michele Restuccia on 9/11/25.
//

import SwiftUI

struct ContentList<Item: Identifiable>: View {
    let items: [Item]
    let title: KeyPath<Item, String>
    typealias Handler = (Item) -> Void
    let onTap: Handler?

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            ForEach(items) { item in
                Button {
                    onTap?(item)
                } label: {
                    row(for: item)
                }
                .buttonStyle(.plain)
                .cornerBackground()
            }
        }
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private func row(for item: Item) -> some View {
        let titleText = item[keyPath: title]
        
        HStack(spacing: 16) {
            Text(titleText)
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
        .combinedAccessibility()
        .accessibilityLabel(Text(titleText))
    }
}
