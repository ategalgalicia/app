//
//  Created by Michele Restuccia on 13/12/25.
//

import SwiftUI

public struct EmptyStateView: View {
    
    private let txt: LocalizedStringKey
    private let image: Image?
    private let button: (title: LocalizedStringKey, action: VoidHandler)?
    
    public init(
        txt: LocalizedStringKey,
        image: Image? = nil,
        button: (title: LocalizedStringKey, action: VoidHandler)? = nil
    ) {
        self.txt = txt
        self.image = image
        self.button = button
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            if let image {
                image
                    .frame(width: 44, height: 44)
                    .padding(8)
                    .foregroundStyle(.white)
                    .background(ColorsPalette.primary)
                    .clipShape(Circle())
            }
            
            Text(txt)
                .font(.callout)
                .foregroundStyle(ColorsPalette.textPrimary)
                .multilineTextAlignment(.center)
            
            if let button {
                Button(
                    action: {
                        button.action()
                    }, label: {
                        Text(button.title)
                            .primaryTitle()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                )
                .frame(minHeight: 48)
                .padding(16)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
