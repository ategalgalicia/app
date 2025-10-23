//
//  Created by Michele Restuccia on 23/10/25.
//

import SwiftUI

typealias VoidHandler = @MainActor () -> ()
typealias AsyncVoidHandler = @MainActor () async throws -> ()

extension View {
    /// Attach an action bar to the bottom of the screen/container.
    /// - On Darwin platforms (iOS, macOS, tvOS, watchOS) it uses `safeAreaInset(edge: .bottom)`.
    /// - On non-Darwin platforms it falls back to a `VStack` with the action view placed at the bottom.
    @ViewBuilder
    func actionView<V: View>(@ViewBuilder content: () -> V) -> some View {
        #if canImport(Darwin)
        self.safeAreaInset(edge: .bottom) {
            content()
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        #else
        VStack(spacing: 0) {
            self
            Spacer()
            content()
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        #endif
    }
}
