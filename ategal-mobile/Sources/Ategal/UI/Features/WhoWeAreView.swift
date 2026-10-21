//
//  Created by Michele Restuccia on 3/12/25.
//

import SwiftUI
import AtegalCore
import RStudioKit

#if canImport(Darwin)

// MARK: - Previews

#Preview {
    NavigationStack {
        WhoWeAreView(
            centers: []
        )
        .dynamicTypeSize(.large ... .accessibility5)
    }
}
#endif

// MARK: - WhoWeAreView

struct WhoWeAreView: View {
    
    @State
    var selectedCenter: Center? = nil
    
    let centers: [Center]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 36) {
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
        .sheet(item: $selectedCenter) { selectedCenter in
            cityView(center: selectedCenter)
        }
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(ategal: "logo-icon")
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
                .font(.body.weight(.regular))
                .foregroundStyle(ColorsPalette.textSecondary)
                .multilineTextAlignment(.leading)
                .lineSpacing()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .combinedAccessibility()
    }
    
    @ViewBuilder
    private func section<Content: View>(
        title: LocalizedStringKey,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(ColorsPalette.textPrimary)
                .accessibilityHeading(.h2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            content()
        }
        .padding(.top, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
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
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundColor(ColorsPalette.textPrimary)
                                    .multilineTextAlignment(.leading)
                                
                                Text(center.address)
                                    .font(.subheadline)
                                    .foregroundColor(ColorsPalette.textSecondary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            
                            Text("who-we-are-where-action")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(ColorsPalette.textTertiary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .ategalCornerPrimaryBackground()
                        }
                        .padding(16)
                    }
                    .ategalCornerBackground()
                }
            }
        }
    }
    
    @ViewBuilder
    private func subtitleView(_ txt: LocalizedStringKey) -> some View {
        Text(txt)
            .font(.body.weight(.regular))
            .foregroundStyle(ColorsPalette.textSecondary)
            .multilineTextAlignment(.leading)
            .lineSpacing()
    }
    
    @ViewBuilder
    private var webButton: some View {
        Link(destination: URL(string: "https://www.ategal.com")!) {
            HStack(alignment: .center, spacing: 8) {
                Text("who-we-are-what-we-do-action")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Text("who-we-are-where-action")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(ColorsPalette.textTertiary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .buttonStyle(.plain)
                    .ategalCornerPrimaryBackground()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .ategalCornerBackground()
        .cornerBorder()
    }
    
    @ViewBuilder
    private func cityView(center: Center) -> some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    LinkView(
                        phoneNumbers: center.phone,
                        email: center.email
                    )
                    
                    LinkView(
                        address: center.address,
                        lat: center.latitude,
                        long: center.longitude
                    )
                    MapView(place: center.place)
                }
                .padding(.horizontal, 16)
            }
            .background(ColorsPalette.background)
            .navigationTitle(center.city)
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .presentationDetents({
                #if canImport(Darwin)
                [.medium, .large]
                #else
                [.large]
                #endif
                }()
            )
            .toolbarWithDismissButton()
        }
        .tint(ColorsPalette.primary)
    }
}

// MARK: Async

struct WhoWeAreAsyncView: View {
    
    let apiClient: GistAPIClient
    
    var body: some View {
        NavigationStack {
            AsyncView {
                await apiClient.fetchCenters()
            } content: {
                WhoWeAreView(centers: $0)
            }
            .background(ColorsPalette.background)
            .navigationTitle("tab-who-we-are")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(ColorsPalette.primary)
        .accessibilityHeading(.h1)
    }
}
