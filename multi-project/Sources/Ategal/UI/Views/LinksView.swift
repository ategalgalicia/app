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
    
    init(
        phoneNumbers: [String] = [],
        email: String? = nil,
        website: String? = nil,
        address: String? = nil
    ) {
        self.phoneNumbers = phoneNumbers
        self.email = email
        self.website = website
        self.address = address
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let email, let url = ExternalActions.shared.emailURL(to: email) {
                Link(destination: url) {
                    LinkButton(txt: email, icon: "envelope.fill")
                }
            }
            if !phoneNumbers.isEmpty {
                ForEach(phoneNumbers, id: \.self) { number in
                    if let url = ExternalActions.shared.phoneURL(for: number) {
                        Link(destination: url) {
                            LinkButton(txt: number, icon: "phone.fill")
                        }
                    }
                }
            }
            if let address {
                MapLinkButton(address: address, lat: 0, lon: 0)
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
            LinkButton(txt: address, icon: "mappin.circle.fill")
        }
        .confirmationDialog(
            "", isPresented: $showDirectionsDialog,
            titleVisibility: .hidden
        ) {
            Button {
                ExternalActions.shared.open(on: .apple, lat: lat, lon: lon)
            } label: {
                Text(verbatim: "Apple Maps")
            }
            Button {
                ExternalActions.shared.open(on: .google, lat: lat, lon: lon)
            } label: {
                Text(verbatim: "Google Maps")
            }
            Button("cancel", role: .cancel) {}
        }
        #else
        if let url = ExternalActions.shared.androidMapsURL(for: address) {
            Link(destination: url) {
                LinkButton(txt: address, icon: "mappin.circle.fill")
            }
        }
        #endif
    }
}

struct LinkButton: View {
    
    let txt: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(txt)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(ColorsPalette.textPrimary)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Image(systemName: icon)
                .foregroundStyle(ColorsPalette.textTertiary)
                .frame(width: 24)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .cornerBackground(ColorsPalette.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .cornerBackground(ColorsPalette.background.opacity(0.95))
        .cornerBorder()
    }
}
