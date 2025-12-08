//
//  Created by Michele Restuccia on 8/12/25.
//

import SwiftUI

struct LinkButton: View {
    
    let title: String
    let kind: CTAButton.Kind
    let url: URL
    
    var body: some View {
        Link(destination: url) {
            CTAButton(title: title, kind: kind)
        }
        .cornerBackground(ColorsPalette.background.opacity(0.95))
        .cornerBorder()
    }
}

struct CTAButton: View {
    
    let title: String
    let kind: Kind
    enum Kind {
        case txt(String)
        case icon(String)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(ColorsPalette.textPrimary)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            switch kind {
            case .txt(let txt):
                Text(txt)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ColorsPalette.textTertiary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .buttonStyle(.plain)
                    .cornerBackground(ColorsPalette.primary)
                
            case .icon(let icon):
                Image(systemName: icon)
                    .foregroundStyle(ColorsPalette.textTertiary)
                    .frame(width: 24)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .cornerBackground(ColorsPalette.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
