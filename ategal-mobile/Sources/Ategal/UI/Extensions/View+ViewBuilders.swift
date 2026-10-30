//
//  Created by Michele Restuccia on 23/10/25.
//

import SwiftUI
import RStudioKit

#if SKIP
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.unit.dp
#endif

extension View {
    
    @ViewBuilder
    func ategalBottomActionBar<V: View>(
        isPresented: Bool = true,
        @ViewBuilder _ content: () -> V
    ) -> some View {
        if isPresented {
            self.bottomActionBar {
                content()
                    .padding([.horizontal, .top], 16)
                    #if canImport(UIKit)
                    .modifier(BottomPaddingCompensatorModifier())
                    #elseif os(Android)
                    .background(
                        ColorsPalette.background,
                        ignoresSafeAreaEdges: .bottom
                    )
                    #endif
            }
        } else {
            self
        }
    }
    
    @ViewBuilder
    func ategalNavigationBarConfiguration() -> some View {
        #if os(Android)
        self.composeModifier {
            AtegalNavigationBarModifier(
                backgroundColor: ColorsPalette.background
            )
        }
        #else
        self
        #endif
    }

    @ViewBuilder
    func ategalTabBarConfiguration() -> some View {
        #if os(Android)
        self
            .tabBarMinimizeBehavior()
            .composeModifier {
                AtegalTabBarModifier(
                    backgroundColor: ColorsPalette.backgroundSecondary,
                    borderColor: ColorsPalette.border
                )
            }
        #else
        self.tabBarMinimizeBehavior()
        #endif
    }
    
    @ViewBuilder
    func toolbarIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            #if os(Android)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .padding(8)
            .background(ColorsPalette.backgroundSecondary)
            #endif
    }
    
    @ViewBuilder
    func accessibility(label: String, hint: String? = nil) -> some View {
        #if canImport(Darwin)
        if let hint = hint {
            self.accessibilityLabel(label)
                .accessibilityHint(hint)
        } else {
            self.accessibilityLabel(label)
        }
        #else
        self
        #endif
    }
    
    @ViewBuilder
    func applyAccessibility() -> some View {
        #if canImport(Darwin)
        self.dynamicTypeSize(.small ... .accessibility2)
        #else
        self
        #endif
    }
    
    @ViewBuilder
    func combinedAccessibility() -> some View {
        #if canImport(Darwin)
        self.accessibilityElement(children: .combine)
        #else
        self
        #endif
    }
}

#if SKIP
// SKIP INSERT: @OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)
struct AtegalNavigationBarModifier: ContentModifier {
    let backgroundColor: Color

    func modify(view: any View) -> any View {
        view.material3TopAppBar { options in
            let color = backgroundColor.asComposeColor()
            options.copy(
                colors: options.colors.copy(
                    containerColor: color,
                    scrolledContainerColor: color
                ),
                preferCenterAlignedStyle: true
            )
        }
    }
}

struct AtegalTabBarModifier: ContentModifier {
    let backgroundColor: Color
    let borderColor: Color

    func modify(view: any View) -> any View {
        view.material3NavigationBar { options in
            let composeBackgroundColor = backgroundColor.asComposeColor()
            let composeBorderColor = borderColor.asComposeColor()

            options.copy(
                modifier: options.modifier.drawWithContent {
                    drawContent()
                    drawLine(
                        color: composeBorderColor,
                        start: Offset(x: Float(0.0), y: Float(0.0)),
                        end: Offset(x: size.width, y: Float(0.0)),
                        strokeWidth: 1.dp.toPx()
                    )
                },
                containerColor: composeBackgroundColor,
                tonalElevation: 0.dp
            )
        }
    }
}
#endif

#if canImport(UIKit)

private struct BottomPaddingCompensatorModifier: ViewModifier {
    
    @State
    private var bottomSafeArea: CGFloat = 0
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            /// iOS 26 safeAreaBar already provides enough bottom spacing when the local
            /// safe area is large. In compact containers like iPad form sheets, the local
            /// bottom safe area can be small, so compensate with extra bottom padding.
            content
                .padding(.bottom, bottomSafeArea > 25 ? 0 : 16)
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear { bottomSafeArea = proxy.safeAreaInsets.bottom }
                            .onChange(of: proxy.safeAreaInsets.bottom) { _, value in
                                bottomSafeArea = value
                            }
                    }
                }
        } else {
            content
        }
    }
}
#endif
