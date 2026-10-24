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
                    title: "who-we-are-what-we-do".localized,
                    content: {
                        VStack(alignment: .leading, spacing: 16) {
                            subtitleView("who-we-are-what-we-do-description".localized)
                            webButton
                        }
                    }
                )
                
                section(
                    title: "who-we-are-where".localized,
                    content: {
                        VStack(alignment: .leading, spacing: 24) {
                            centersView
                            subtitleView("who-we-are-contact-description".localized)
                        }
                    }
                )
            }
            .padding([.horizontal, .bottom], 16)
        }
        .sheet(item: $selectedCenter) { selectedCenter in
            cityView(center: selectedCenter)
        }
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ategal-title".localized)
                .font(.title2.weight(.semibold))
                .foregroundStyle(ColorsPalette.textPrimary)
                .multilineTextAlignment(.leading)
                .accessibilityHeading(.h1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("who-we-are-description".localized)
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
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .primaryTitle()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            content()
        }
        .padding(.top, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .combinedAccessibility()
    }
    
    @ViewBuilder
    private var centersView: some View {
        VStack(alignment: .leading, spacing: 16) {
            subtitleView("who-we-are-where-description".localized)
            
            VStack(spacing: 8) {
                ForEach(centers) { center in
                    Button {
                        selectedCenter = center
                    } label: {
                        HStack(alignment: .center, spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(center.city)
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(ColorsPalette.textPrimary)
                                    .multilineTextAlignment(.leading)
                                
                                Text(center.address)
                                    .font(.body)
                                    .foregroundColor(ColorsPalette.textSecondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "arrow.forward.square")
                                .accessibilityHidden(true)
                                .foregroundStyle(ColorsPalette.textTertiary)
                                .frame(width: 24)
                                .font(.body)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .ategalCornerPrimaryBackground()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .ategalCornerBackground()
                }
            }
        }
    }
    
    @ViewBuilder
    private func subtitleView(_ txt: String) -> some View {
        Text(txt)
            .font(.body.weight(.regular))
            .foregroundStyle(ColorsPalette.textSecondary)
            .multilineTextAlignment(.leading)
            .lineSpacing()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var webButton: some View {
        Link(destination: URL(string: "https://www.ategal.com")!) {
            HStack(alignment: .center, spacing: 8) {
                Text("who-we-are-what-we-do-action".localized)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "arrow.forward.square")
                    .accessibilityHidden(true)
                    .foregroundStyle(ColorsPalette.textTertiary)
                    .frame(width: 24)
                    .font(.body)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
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
            .navigationTitle("tab-who-we-are".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
        .accessibilityHeading(.h1)
    }
}
