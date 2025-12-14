//
//  Created by Michele Restuccia on 3/12/25.
//

import SwiftUI
import AtegalCore

#if canImport(Darwin)

// MARK: Previews

#Preview {
    NavigationStack {
        WhoWeAreView(
            apiClient: .init()
        )
        .dynamicTypeSize(.large ... .accessibility5)
    }
}
#endif

struct WhoWeAreView: View {
    
    @State
    var selectedCenter: Center? = nil
    
    let centers: [Center]
    
    init(apiClient: AtegalAPIClient) {
        self.centers = apiClient.fetchCenters()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerView
                
                section(
                    title: "who-we-are-what-we-do",
                    systemImage: "person",
                    content: {
                        VStack(spacing: 16) {
                            subtitleView("who-we-are-what-we-do-description")
                            webButton
                        }
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
            .padding(16)
        }
        .navigationTitle("tab-who-we-are")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedCenter) { selectedCenter in
            CityView(center: selectedCenter)
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
            
            Text("ategal-title")
                .font(.title.weight(.bold))
                .foregroundStyle(ColorsPalette.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
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
                    .font(.body)
                    .fontWeight(.bold)
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
                    Button {
                        selectedCenter = center
                    } label: {
                        HStack(alignment: .center, spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(center.city)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(ColorsPalette.textPrimary)
                                    .multilineTextAlignment(.leading)
                                
                                Text(center.address)
                                    .font(.footnote)
                                    .foregroundColor(ColorsPalette.textSecondary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            
                            Text("who-we-are-where-action")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(ColorsPalette.textTertiary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .cornerBackground(ColorsPalette.primary)
                        }
                        .padding(16)
                    }
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
    
    @ViewBuilder
    private var webButton: some View {
        Link(destination: URL(string: "https://www.ategal.com")!) {
            HStack(alignment: .center, spacing: 8) {
                Text("who-we-are-what-we-do-action")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Text("who-we-are-where-action")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ColorsPalette.textTertiary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .buttonStyle(.plain)
                    .cornerBackground(ColorsPalette.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .cornerBackground(ColorsPalette.background.opacity(0.95))
        .cornerBorder()
    }
}
