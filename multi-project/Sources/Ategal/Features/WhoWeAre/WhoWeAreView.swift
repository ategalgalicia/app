//
//  Created by Michele Restuccia on 3/12/25.
//

import SwiftUI
import AtegalCore

#if canImport(Darwin)

// MARK: Previews

@available(iOS 18, *)
#Preview {
    @Previewable
    @State
    var navigationPath: [HomeRoute] = []
    
    NavigationStack {
        WhoWeAreView(
            centers: []
        )
        .dynamicTypeSize(.large ... .accessibility5)
    }
}
#endif

struct WhoWeAreView: View {
    
    @State
    var selectedCenter: Center? = nil
    
    let centers: [Center]
    
    init(centers: [Center]) {
        self.centers = centers
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerView
                
                section(
                    title: "who-we-are-what-we-do",
                    systemImage: "person",
                    content: {
                        subtitleView("who-we-are-what-we-do-description")
                    }
                )
                
                section(
                    title: "who-we-are-where",
                    systemImage: "mappin.circle.fill",
                    content: {
                        centersView
                    }
                )
                
                section(
                    title: "who-we-are-contact",
                    systemImage: "phone",
                    content: {
                        subtitleView("who-we-are-contact-description")
                    }
                )
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("tab-who-we-are")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedCenter) { selectedCenter in
            CenterView(center: selectedCenter)
        }
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
    private func section<Content: View>(
        title: LocalizedStringKey,
        systemImage: String,
        @ViewBuilder content: () -> Content
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
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .cornerBackground()
        .combinedAccessibility()
    }
    
    @ViewBuilder
    private var centersView: some View {
        VStack(spacing: 16) {
            subtitleView("who-we-are-where-description")
            
            VStack(spacing: 8) {
                ForEach(centers) { center in
                    HStack(alignment: .center, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(center.city)
                                .font(.subheadline.bold())
                                .foregroundColor(ColorsPalette.textPrimary)
                            
                            Text(center.address)
                                .font(.footnote)
                                .foregroundColor(ColorsPalette.textSecondary)
                        }
                        Spacer()
                        
                        Button {
                            selectedCenter = center
                        } label: {
                            Text("who-we-are-where-action")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(ColorsPalette.textTertiary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        .cornerBackground(ColorsPalette.primary)
                    }
                    .padding(16)
                    .cornerBackground(ColorsPalette.background)
                }
            }
        }
    }
    
    @ViewBuilder
    private func subtitleView(_ txt: LocalizedStringKey) -> some View {
        Text(txt)
            .font(.subheadline.weight(.regular))
            .foregroundStyle(ColorsPalette.textSecondary)
            .multilineTextAlignment(.leading)
            .lineSpacing()
    }
}
