//
//  Created by Michele Restuccia on 6/12/25.
//

import SwiftUI
import AtegalCore

struct CenterView: View {
    
    let center: Center
    
    @State
    var detentSelection: PresentationDetent = .medium
    
    var body: some View {
        NavigationStack {
            contentView
        }
        .tint(ColorsPalette.textPrimary)
        .presentationDetents(detents: [.medium, .large], selection: $detentSelection)
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(center.city)
                        .font(.title.bold())
                        .foregroundColor(ColorsPalette.textPrimary)
                    
                    Text(center.address)
                        .font(.subheadline)
                        .foregroundColor(ColorsPalette.textSecondary)
                }
                
                MapView(places: [center.place])
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                
                moreInfoView
            }
            .padding(16)
        }
        .toolbarWithDismissButton()
        .actionView {
            if let url = ExternalActions.shared.googleMapsURL(for: center.address) {
                Link(destination: url) {
                    Text("center-action")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(ColorsPalette.textTertiary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .cornerBackground(ColorsPalette.primary)
                        .padding(16)
                }
            }
        }
    }
    
    @ViewBuilder
    private var moreInfoView: some View {
        #if canImport(Darwin)
        if detentSelection.isLarge {
            MoreInfoView(center: center)
        }
        #else
        MoreInfoView(center: center)
        #endif
    }
}

//MARK: Extensions

private extension PresentationDetent {
    
    var isLarge: Bool {
        self == .large
    }
}
