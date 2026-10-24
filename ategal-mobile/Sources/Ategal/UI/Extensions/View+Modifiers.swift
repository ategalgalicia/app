//
//  Created by Michele Restuccia on 6/12/25.
//

import SwiftUI

extension View {
    
    func primaryTitle() -> some View {
        modifier(PrimaryTitleModifier())
    }
}

// MARK: - PrimaryTitleModifier

struct PrimaryTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2.weight(.semibold))
            .foregroundStyle(ColorsPalette.textPrimary)
            .multilineTextAlignment(.leading)
            .accessibilityHeading(.h2)
    }
}
