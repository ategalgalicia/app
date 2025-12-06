//
//  Created by Michele Restuccia on 6/12/25.
//

import SwiftUI

extension View {
    
    func cornerBackground(_ color: Color = ColorsPalette.cardBackground, radius: CGFloat = 16) -> some View {
        self
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
    
    func toolbarWithDismissButton(shouldShowDismissButton: Bool = true) -> some View {
        modifier(ToolbarWithDismissButton(shouldShowDismissButton: shouldShowDismissButton))
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
