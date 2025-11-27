//
//  Created by Michele Restuccia on 23/10/25.
//

import SwiftUI
import AtegalCore

#if canImport(Darwin)

// MARK: Previews

@available(iOS 18, *)
#Preview {
    @Previewable
    @State
    var navigationPath: [HomeRoute] = []
    
    NavigationStack {
        HomeView(
            navigationPath: $navigationPath,
            apiClient: .init(environment: .init(host: .production))
        )
    }
}
#endif

// MARK: HomeRoute

enum HomeRoute: Hashable {
    case navigateToCenter
    case navigateToCategory
    case navigateToActivity
}

// MARK: HomeView

struct HomeView: View {
    
    @Binding
    var navigationPath: [HomeRoute]
    
    init(navigationPath: Binding<[HomeRoute]>, apiClient: AtegalAPIClient) {
        self.dataSource = HomeDataSource(apiClient: apiClient)
        self._navigationPath = navigationPath
    }
    
    @State
    var dataSource: HomeDataSource
    
    @State
    var didAnimate = false
    
    private var icon: CGFloat = 150
    
    private var center: Center {
        dataSource.centerSelected!
    }
    
    var body: some View {
        contentView
            .background(ColorsPalette.background)
            .tint(ColorsPalette.primary)
            .toolbarForHome()
            .navigationDestination(for: HomeRoute.self) {
                switch $0 {
                case .navigateToCenter:
                    CenterView(
                        dataSource: dataSource,
                        navigationPath: $navigationPath
                    )
                case .navigateToCategory:
                    CategoryView(
                        dataSource: dataSource,
                        navigationPath: $navigationPath
                    )
                case .navigateToActivity:
                    ActivityView(dataSource: dataSource)
                }
            }
            .task {
                guard !didAnimate else { return }
                didAnimate = true
            }
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 0) {
            Spacer()
            centersView
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .actionView { actionView }
    }
    
    @ViewBuilder
    private var centersView: some View {
        ZStack {
            ForEach(0..<dataSource.centers.count, id: \.self) { index in
                let degrees = Double(index) / Double(dataSource.centers.count) * 360 - 90
                button(dataSource.centers[index], angle: .degrees(degrees), index: index)
            }
            Link(
                destination: URL(string: "https://www.ategal.com/somos/")!
            ) {
                Image("logo-icon", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: icon, height: icon)
                    .scaleEffect(didAnimate ? 1 : 0.9)
                    .opacity(didAnimate ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.3), value: didAnimate)
            }
        }
    }
    
    @ViewBuilder
    private func button(_ item: Center, angle: Angle, index: Int) -> some View {
        Button {
            dataSource.centerSelected = item
            navigationPath.append(.navigateToCenter)
        } label: {
            Text(item.city)
                .font(.title3)
                .foregroundStyle(ColorsPalette.textSecondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
        }
        .cornerBackground()
        .scaleEffect(didAnimate ? 1 : 0.8)
        .opacity(didAnimate ? 1 : 0)
        .animation(
            .easeOut(duration: 0.6).delay(Double(index) * 0.15),
            value: didAnimate
        )
        .offset(
            x: CGFloat(cos(angle.radians)) * 140,
            y: CGFloat(sin(angle.radians)) * 140
        )
    }
    
    @ViewBuilder
    private var actionView: some View {
        VStack {
            Image("xunta-icon", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
        }
    }
}
