//
//  Created by Michele Restuccia on 6/12/25.
//

import SwiftUI
import AtegalCore

struct CityView: View {
    
    let center: Center
    
    @State
    var detentSelection: PresentationDetent = .medium
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("ategal-title")
                .navigationBarTitleDisplayMode(.inline)
        }
        .tint(ColorsPalette.textPrimary)
        .presentationDetents(detents: [.medium, .large], selection: $detentSelection)
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(center.city)
                    .font(.title.bold())
                    .foregroundColor(ColorsPalette.textPrimary)
                
                MapView(place: center.place)
                
                #if canImport(Darwin)
                if detentSelection.isLarge {
                    linkView
                } else {
                    LinkView(address: center.address)
                }
                #else
                linkView
                #endif
            }
            .padding(16)
        }
        .toolbarWithDismissButton()
    }
    
    @ViewBuilder
    private var linkView: some View {
        LinkView(
            phoneNumbers: center.phone,
            email: center.email,
            address: center.address
        )
    }
}

//MARK: Extensions

private extension PresentationDetent {
    
    var isLarge: Bool {
        self == .large
    }
}
