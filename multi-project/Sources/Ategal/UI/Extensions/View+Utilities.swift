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
    
    @ViewBuilder
    func lineSpacing(value: CGFloat = 6) -> some View {
        #if canImport(Darwin)
        self.lineSpacing(value)
        #else
        self
        #endif
    }
    
    @ViewBuilder
    func contentRectangleShape() -> some View {
        #if canImport(Darwin)
        self.contentShape(Rectangle())
        #else
        self
        #endif
    }
    
    @ViewBuilder
    func platformSearchable(text: Binding<String>, prompt: LocalizedStringKey) -> some View {
        #if canImport(Darwin)
        self.searchable(
            text: text,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: prompt
        )
        #else
        self.searchable(
            text: text,
            prompt: prompt
        )
        #endif
    }
    
    func cornerBackground(_ color: Color = ColorsPalette.cardBackground, radius: CGFloat = 16) -> some View {
        self
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
    
    func toolbarWithDismissButton(shouldShowDismissButton: Bool = true) -> some View {
        modifier(ToolbarWithDismissButton(shouldShowDismissButton: shouldShowDismissButton))
    }
}

//MARK: ToolbarWithDismissButton

struct ToolbarWithDismissButton: ViewModifier {
    @Environment(\.dismiss) var dismiss
    let shouldShowDismissButton: Bool
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                if shouldShowDismissButton {
                    ToolbarItem(placement: .topBarLeading) {
                        Button { dismiss() }
                        label: {
                            Image(systemName: "xmark")
                                .foregroundColor(ColorsPalette.textPrimary)
                        }
                    }
                }
            }
    }
}
