//
//  Created by Michele Restuccia on 23/10/25.
//

import SwiftUI

public typealias VoidHandler = @MainActor () -> ()
public typealias AsyncVoidHandler = @MainActor () async throws -> ()

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
    
    @ViewBuilder
    func presentationDetents(detents: Set<PresentationDetent>, selection: Binding<PresentationDetent>? = nil) -> some View {
        #if canImport(Darwin)
        if let selection {
            self.presentationDetents(detents, selection: selection)
        } else {
            self.presentationDetents(detents)
        }
        #else
        self.presentationDetents([.large])
        #endif
    }
    
    @ViewBuilder
    func tabBarMinimizeBehavior() -> some View {
        #if canImport(Darwin)
        if #available(iOS 26.0, *) {
            self.tabBarMinimizeBehavior(.onScrollDown)
        } else {
            self
        }
        #else
        self
        #endif
    }
}
