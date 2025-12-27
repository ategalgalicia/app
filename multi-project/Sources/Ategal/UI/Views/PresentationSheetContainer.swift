//
//  Created by Michele Restuccia on 27/12/25.
//

import SwiftUI

struct PresentationSheetContainer<Content: View>: View {
    
    @ViewBuilder
    private let content: () -> Content
    
    private let detents: Set<PresentationDetent>
    private let title: String?
    
    init(
        title: String? = nil,
        detents: Set<PresentationDetent> = [.medium],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.detents = detents
        self.content = content
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    content()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
            }
            .navigationTitle(title ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarWithDismissButton()
        }
        .background(ColorsPalette.background)
        .tint(ColorsPalette.primary)
        .presentationDetents(detents)
    }
}
