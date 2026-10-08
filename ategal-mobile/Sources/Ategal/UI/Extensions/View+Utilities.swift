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
