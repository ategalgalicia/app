//
//  Created by Michele Restuccia on 23/10/25.
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
}
