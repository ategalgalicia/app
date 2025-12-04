//
//  Created by Michele Restuccia on 27/11/25.
//

import SwiftUI
import AtegalCore

struct MoreInfoView: View {
    
    let center: Center
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("more-info-header-title")
                .font(.title3)
                .fontWeight(.regular)
                .foregroundStyle(ColorsPalette.textPrimary)
            
            LinkView(
                phoneNumbers: center.phone,
                email: center.email,
                website: nil,
                address: center.address
            )
            .padding(16)
            .cornerBackground()
        }
    }
}
