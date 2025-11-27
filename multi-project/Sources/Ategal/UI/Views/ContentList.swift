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
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items) { item in
                Button {
                    onTap?(item)
                } label: {
                    HStack {
                        Text(item[keyPath: title].lowercased().capitalized)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(ColorsPalette.textPrimary)
                            .multilineTextAlignment(.leading)

                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(ColorsPalette.primary)
                    }
                    .padding(16)
                    
                }
                if item.id != items.last?.id {
                    Divider()
                        .foregroundStyle(ColorsPalette.textTertiary)
                }
            }
        }
        .cornerBackground()
    }
}
