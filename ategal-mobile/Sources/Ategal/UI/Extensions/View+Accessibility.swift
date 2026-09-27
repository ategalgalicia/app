//
//  Created by Michele Restuccia on 23/10/25.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func accessibility(label: LocalizedStringKey, hint: LocalizedStringKey? = nil) -> some View {
        #if canImport(Darwin)
        if let hint = hint {
            self.accessibilityLabel(label)
                .accessibilityHint(hint)
        } else {
            self.accessibilityLabel(label)
        }
        #else
        self
        #endif
    }
    
    @ViewBuilder
    func applyAccessibility() -> some View {
        #if canImport(Darwin)
        self.dynamicTypeSize(.large ... .accessibility5)
        #else
        self
        #endif
    }
    
    @ViewBuilder
    func combinedAccessibility() -> some View {
        #if canImport(Darwin)
        self.accessibilityElement(children: .combine)
        #else
        self
        #endif
    }
}

