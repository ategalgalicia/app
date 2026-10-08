//
//  Created by Michele Restuccia on 6/12/25.
//

import SwiftUI
import RStudioKit

extension View {
    
    func ategalCornerBackground() -> some View {
        self.cornerBackground(ColorsPalette.backgroundSecondary, radius: 14)
    }
    
    func ategalCornerPrimaryBackground() -> some View {
        self.cornerBackground(ColorsPalette.primary, radius: 14)
    }
    
    func ategalCornerBorder() -> some View {
        self.cornerBorder(ColorsPalette.border, width: 1, radius: 14)
    }

    func primaryTitle() -> some View {
        modifier(PrimaryTitleModifier())
    }
}

// MARK: - ToolbarWithDismissButton

struct ToolbarWithDismissButton: ViewModifier {
    @Environment(\.dismiss) var dismiss
    let shouldShowDismissButton: Bool
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                if shouldShowDismissButton {
                    ToolbarItem(placement: .topBarLeading) {
                        Button { dismiss() }
                        label: {
                            Image(systemName: "xmark")
                                .foregroundColor(ColorsPalette.textPrimary)
                        }
                    }
                }
            }
    }
}

struct PrimaryTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .fontWeight(.medium)
            .foregroundStyle(ColorsPalette.textPrimary)
    }
}
