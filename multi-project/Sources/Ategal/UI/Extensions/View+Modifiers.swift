//
//  Created by Michele Restuccia on 6/12/25.
//

import SwiftUI

extension View {
    
    func cornerBackground(
        _ color: Color = ColorsPalette.cardBackground,
        radius: CGFloat = 16
    ) -> some View {
        self
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .cornerBorder()
    }
    
    func cornerBorder(
        _ color: Color = ColorsPalette.border,
        width: CGFloat = 1,
        radius: CGFloat = 16
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius)
        return clipShape(shape)
            .overlay(shape.strokeBorder(color, lineWidth: width))
    }
    
    func toolbarWithDismissButton(shouldShowDismissButton: Bool = true) -> some View {
        modifier(ToolbarWithDismissButton(shouldShowDismissButton: shouldShowDismissButton))
    }

    func primaryTitle() -> some View {
        modifier(PrimaryTitleModifier())
    }
}

//MARK: ToolbarWithDismissButton

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
            .font(.title3)
            .fontWeight(.regular)
            .foregroundStyle(ColorsPalette.textPrimary)
    }
}
