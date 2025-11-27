//
//  Created by Michele Restuccia on 13/11/25.
//

import SwiftUI
import AtegalCore

struct LinkView: View {
    
    let phoneNumbers: [String]
    let email: String?
    let website: String?
    let address: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !phoneNumbers.isEmpty {
                ForEach(phoneNumbers, id: \.self) { number in
                    if let url = ExternalActions.shared.phoneURL(for: number) {
                        Link(destination: url) {
                            Label {
                                Text(number)
                                    .underline(true)
                            } icon: {
                                Image(systemName: "phone.fill")
                                    .foregroundStyle(ColorsPalette.primary)
                            }
                        }
                    }
                }
            }
            if let email, let url = ExternalActions.shared.emailURL(to: email) {
                Link(destination: url) {
                    Label {
                        Text(email)
                            .underline(true)
                    } icon: {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(ColorsPalette.primary)
                    }
                }
            }
            if let address, let url = ExternalActions.shared.googleMapsURL(for: address) {
                Link(destination: url) {
                    Label {
                        Text(address)
                            .underline(true)
                            .multilineTextAlignment(.leading)
                    } icon: {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(ColorsPalette.primary)
                    }
                }
            }
            if let website, let url = ExternalActions.shared.websiteURL(from: website) {
                Link(destination: url) {
                    Label {
                        Text(website)
                            .underline(true)
                            .multilineTextAlignment(.leading)
                    } icon: {
                        Image(systemName: "star.fill")
                            .foregroundStyle(ColorsPalette.primary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(ColorsPalette.textPrimary)
        .font(.subheadline)
        .fontWeight(.bold)
    }
}
