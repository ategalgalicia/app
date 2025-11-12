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
        }
        .background(ColorsPalette.background)
        #endif
    }
}

extension View {
    
    func cornerBackground(_ color: Color = ColorsPalette.cardBackground, radius: CGFloat = 16) -> some View {
        self
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
    
    /// Displays the ATEGAL home toolbar title in the center.
    func toolbarForHome() -> some View {
        modifier(HomeTitleModifier())
    }
}

// MARK: HomeTitleModifier

struct HomeTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if canImport(Darwin)
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    label
                }
            }
        #else
        VStack(spacing: 0) {
            label
            Spacer()
            content
        }
        .background(ColorsPalette.background)
        #endif
    }
    
    private var label: some View {
        VStack(alignment: .center) {
            Text("ategal-title")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(ColorsPalette.textPrimary)

            Text("ategal-subtitle")
                .font(.footnote)
                .foregroundColor(ColorsPalette.textSecondary)
        }
    }
}
