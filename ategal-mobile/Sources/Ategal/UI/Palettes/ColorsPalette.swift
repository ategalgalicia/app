//
//  Created by Michele Restuccia on 8/11/25.
//

import SwiftUI

struct ColorsPalette {
    static let primary          = Color(hex: "#008DCB")
    static let background       = Color(hex: "#FFFFFF")
    static let cardBackground   = Color(hex: "#F4F7F8")
    static let textPrimary      = Color(hex: "#1A1A1A")
    static let textSecondary    = Color(hex: "#6B6B6B")
    static let textTertiary     = Color(hex: "#F4F4F4")
    static let border           = Color(hex: "#F5F5F5")
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >>  8) & 0xFF) / 255
        let b = Double((rgb >>  0) & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
