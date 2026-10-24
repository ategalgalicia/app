//
//  Created by Michele Restuccia on 13/11/25.
//

import SwiftUI
import AtegalCore
import RStudioKit

struct LinkView: View {
    
    private let phoneNumbers: [String]
    private let email: String?
    private let website: String?
    private let address: String?
    private let lat: Double?
    private let long: Double?
    
    init(
        phoneNumbers: [String] = [],
        email: String? = nil,
        website: String? = nil,
        address: String? = nil,
        lat: Double? = nil,
        long: Double? = nil
    ) {
        self.phoneNumbers = phoneNumbers
        self.email = email
        self.website = website
        self.address = address
        self.lat = lat
        self.long = long
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let address, let lat, let long {
                MapLinkButton(address: address, lat: lat, lon: long)
            }
            if !phoneNumbers.isEmpty {
                ForEach(phoneNumbers, id: \.self) { number in
                    if let url = LinkHelper.shared.phoneURL(for: number) {
                        LinkButton(title: number, kind: .icon("phone.fill"), url: url)
                    }
                }
            }
            if let email, let url = LinkHelper.shared.emailURL(to: email) {
                LinkButton(title: email, kind: .icon("envelope.fill"), url: url)
            }
            if let website, let url = LinkHelper.shared.websiteURL(from: website) {
                LinkButton(title: website, kind: .icon("arrow.forward"), url: url)
            }
        }
    }
}

struct MapLinkButton: View {
    
    let address: String
    let lat: Double
    let lon: Double
    
    @State
    var showDirectionsDialog = false

    private var directionsLabel: some View {
        Text("map-directions-action".localized)
            .font(.body.weight(.medium))
            .foregroundStyle(ColorsPalette.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .chevronOverlay()
            .contentRectangleShape()
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .ategalCornerBackground()
    }
    
    var body: some View {
        #if canImport(Darwin)
        Button {
            showDirectionsDialog = true
        } label: {
            directionsLabel
        }
        .confirmationDialog(
            Text(verbatim: ""), isPresented: $showDirectionsDialog, titleVisibility: .hidden
        ) {
            Button {
                LinkHelper.shared.open(on: .apple, lat: lat, lon: lon)
            } label: {
                Text(verbatim: "Apple Maps")
            }
            Button {
                LinkHelper.shared.open(on: .google, lat: lat, lon: lon)
            } label: {
                Text(verbatim: "Google Maps")
            }
            Button("cancel", role: .cancel) {}
        }
        #else
        if let url = LinkHelper.shared.androidMapsURL(for: address) {
            Link(destination: url) {
                directionsLabel
            }
        }
        #endif
    }
}
