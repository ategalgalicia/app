//
//  Created by Michele Restuccia on 8/11/25.
//

import SwiftUI

struct ColorsPalette {
    static let primary        = Color(hex: "#008DCB")
    static let primaryDark    = Color(hex: "#006B9A")
    static let primaryLight   = Color(hex: "#E0F3FB")

    static let secondary      = Color(hex: "#F2C94C")
    static let secondaryDark  = Color(hex: "#DAA727")

    static let background     = Color(hex: "#FFFFFF")
    static let cardBackground = Color(hex: "#F4F7F8")
    static let textPrimary    = Color(hex: "#1A1A1A")
    static let textSecondary  = Color(hex: "#4A4A4A")

    static let success        = Color(hex: "#4CAF50")
    static let warning        = Color(hex: "#ED9E3A")
    static let error          = Color(hex: "#D9534F")
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
