//
//  Created by Michele Restuccia on 13/11/25.
//

import SwiftUI
import AtegalCore

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
            if !phoneNumbers.isEmpty {
                ForEach(phoneNumbers, id: \.self) { number in
                    if let url = LinkManager.shared.phoneURL(for: number) {
                        LinkButton(title: number, kind: .icon("phone.fill"), url: url)
                    }
                }
            }
            if let email, let url = LinkManager.shared.emailURL(to: email) {
                LinkButton(title: email, kind: .icon("envelope.fill"), url: url)
            }
            if let address, let lat, let long {
                MapLinkButton(address: address, lat: lat, lon: long)
            }
            if let website, let url = LinkManager.shared.websiteURL(from: website) {
                LinkButton(title: website, kind: .icon("star.fill"), url: url)
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
    
    var body: some View {
        #if canImport(Darwin)
        Button {
            showDirectionsDialog = true
        } label: {
            CTAButton(title: address, kind: .icon("mappin.circle.fill"))
                .cornerBackground(ColorsPalette.background.opacity(0.95))
                .cornerBorder()
        }
        .confirmationDialog(
            "", isPresented: $showDirectionsDialog,
            titleVisibility: .hidden
        ) {
            Button {
                LinkManager.shared.open(on: .apple, lat: lat, lon: lon)
            } label: {
                Text(verbatim: "Apple Maps")
            }
            Button {
                LinkManager.shared.open(on: .google, lat: lat, lon: lon)
            } label: {
                Text(verbatim: "Google Maps")
            }
            Button("cancel", role: .cancel) {}
        }
        #else
        if let url = LinkManager.shared.androidMapsURL(for: address) {
            LinkButton(title: address, kind: .icon("mappin.circle.fill"), url: url)
        }
        #endif
    }
}
