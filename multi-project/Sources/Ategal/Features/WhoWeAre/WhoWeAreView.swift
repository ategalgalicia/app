//
//  Created by Michele Restuccia on 3/12/25.
//

import SwiftUI

struct WhoWeAreView: View {
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerView
                section(
                    title: "who-we-are-what-we-do",
                    subtitle: "who-we-are-what-we-do-description",
                    systemImage: "person"
                )
                section(
                    title: "who-we-are-where",
                    subtitle: "who-we-are-where-description",
                    systemImage: "mappin.circle.fill"
                )
                section(
                    title: "who-we-are-contact",
                    subtitle: "who-we-are-contact-description",
                    systemImage: "phone"
                )
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("tab-who-we-are")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 16) {
            Image("logo-icon", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .accessibilityHidden(true)
            
            Text("who-we-are-description")
                .font(.subheadline.weight(.regular))
                .foregroundStyle(ColorsPalette.textSecondary)
                .multilineTextAlignment(.leading)
                .lineSpacing()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .cornerBackground()
        .combinedAccessibility()
    }
    
    @ViewBuilder
    private func section(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey,
        systemImage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(ColorsPalette.primary)
                    .padding(8)
                    .cornerBackground(ColorsPalette.primary.opacity(0.15), radius: 8)
                    .accessibilityHidden(true)
                
                Text(title)
                    .font(.headline.bold())
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .multilineTextAlignment(.leading)
                    .accessibilityHeading(.h2)
            }
            
            Text(subtitle)
                .font(.subheadline.weight(.regular))
                .foregroundStyle(ColorsPalette.textSecondary)
                .multilineTextAlignment(.leading)
                .lineSpacing()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .cornerBackground()
        .combinedAccessibility()
    }
}
