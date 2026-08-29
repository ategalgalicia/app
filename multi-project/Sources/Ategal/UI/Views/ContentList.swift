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
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items) { item in
                Button {
                    onTap?(item)
                } label: {
                    row(for: item)
                }
                .buttonStyle(.plain)
                .ategalCornerBackground()
            }
        }
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private func row(for item: Item) -> some View {
        let title = item[keyPath: title]
        Text(title)
            .font(.body.weight(.regular))
            .foregroundStyle(ColorsPalette.textSecondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .chevronOverlay()
            .padding(16)
            .contentRectangleShape()
            .combinedAccessibility()
            .accessibilityLabel(Text(title))
    }
}
