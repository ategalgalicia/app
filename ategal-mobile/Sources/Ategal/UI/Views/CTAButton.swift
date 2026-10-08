//
//  Created by Michele Restuccia on 8/12/25.
//

import SwiftUI
import RStudioKit

struct LinkButton: View {
    
    let title: String
    let kind: CTAButton.Kind
    let url: URL
    
    var body: some View {
        Link(destination: url) {
            CTAButton(title: title, kind: kind)
        }
        .ategalCornerBorder()
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
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(ColorsPalette.textPrimary)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            switch kind {
            case .txt(let txt):
                Text(txt)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(ColorsPalette.textTertiary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .buttonStyle(.plain)
                    .ategalCornerPrimaryBackground()
                
            case .icon(let icon):
                Image(systemName: icon)
                    .foregroundStyle(ColorsPalette.textTertiary)
                    .frame(width: 24)
                    .font(.body)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .ategalCornerPrimaryBackground()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ategalCornerBackground()
        .ategalCornerBorder()
    }
}
