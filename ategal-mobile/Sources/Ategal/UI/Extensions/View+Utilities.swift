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
    func ategalTabBarConfiguration() -> some View {
        #if os(Android)
        self
            .tabBarMinimizeBehavior()
            .composeModifier {
                AtegalTabBarModifier(
                    backgroundColor: ColorsPalette.background,
                    borderColor: ColorsPalette.border
                )
            }
        #else
        self.tabBarMinimizeBehavior()
        #endif
    }
}

#if SKIP
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
