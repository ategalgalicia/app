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
        HomeView($navigationPath)
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
    
    @State
    var dataSource: HomeDataSource
    
    init(_ navigationPath: Binding<[HomeRoute]>) {
        self.dataSource = HomeDataSource()
        self._navigationPath = navigationPath
    }
    
    @Binding
    var navigationPath: [HomeRoute]
    
    @State
    var didAnimate = false
    
    private var icon: CGFloat = 150
    
    private var center: Center {
        dataSource.centerSelected!
    }
    
    var body: some View {
        contentView
            .navigationTitle("tab-home")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .navigateToCenter:
                    CenterView(dataSource: dataSource, navigationPath: $navigationPath)
                    
                case .navigateToCategory:
                    CategoryView(dataSource: dataSource, navigationPath: $navigationPath)
                    
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
        .actionView {
            actionView
                .padding(.bottom, 48)
        }
    }
    
    @ViewBuilder
    private var centersView: some View {
        ZStack {
            ForEach(0..<dataSource.centers.count, id: \.self) { index in
                let degrees = Double(index) / Double(dataSource.centers.count) * 360 - 90
                button(dataSource.centers[index], angle: .degrees(degrees), index: index)
            }
            
            Image("logo-icon", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: icon, height: icon)
                .scaleEffect(didAnimate ? 1 : 0.9)
                .opacity(didAnimate ? 1 : 0)
                .animation(
                    .easeOut(duration: 0.4).delay(0.3),
                    value: didAnimate
                )
        }
    }
    
    @ViewBuilder
    private func button(_ item: Center, angle: Angle, index: Int) -> some View {
        Button {
            dataSource.centerSelected = item
            navigationPath.append(.navigateToCenter)
        } label: {
            Text(item.city)
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(16)
        }
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
                .frame(height: 50)
                .padding(16)
        }
    }
}

// MARK: HomeDataSource

@Observable
@MainActor
class HomeDataSource {
    var centers: [Center] = []
    var centerSelected: Center? = nil
    var categorySelected: AtegalCore.Category? = nil
    var activitySelected: Activity? = nil
    
    init() {
        self.centers = [
            readFromBundleFor(center: "santiago"),
            readFromBundleFor(center: "coruna"),
            readFromBundleFor(center: "ferrol"),
            readFromBundleFor(center: "ourense"),
            readFromBundleFor(center: "padron"),
            readFromBundleFor(center: "vigo"),
        ]
    }
    
    private func readFromBundleFor(center: String) -> Center {
        let url = Bundle.module.url(forResource: center, withExtension: "json")
        if url != nil {
            logger.info("Reading JSON for \(center)")
        } else {
            logger.info("Reading JSON failed no URL")
        }
        guard let url,
              let json = try? Data(contentsOf: url, options: .mappedIfSafe),
              let preferences = try? JSONDecoder().decode(Center.self, from: json) else {
            fatalError()
        }
        return preferences
    }
    
    /// For Preview
    static func mock() -> HomeDataSource {
        HomeDataSource()
    }
}

private enum MockHome {
    
    static func center(id: Center.ID) -> Center {
        .init(
            id: id,
            city: "City \(id)",
            address: "Via del corso, 10",
            phone: ["987987987"],
            email: "test1@gmail.com",
            categories: [
                category(id: "0001"),
                category(id: "0002"),
                category(id: "0003")
            ]
        )
    }
    
    static func category(id: AtegalCore.Category.ID) -> AtegalCore.Category {
        .init(
            id: id,
            title: "Category \(id)",
            activities: [
                activity(title: "0001"),
                activity(title: "0002"),
                activity(title: "0003")
            ],
            resources: [
                resource(title: "0001"),
                resource(title: "0002"),
                resource(title: "0003")
            ]
        )
    }
    
    static func activity(title: String) -> Activity {
        .init(
            title: title,
            schedule: "Hoy",
            level: [],
            description: "description",
            address: "Via del corso, 10",
            phone: ["987987987"],
            email: "test1@gmail.com"
        )
    }
    
    static func resource(title: String) -> Resource {
        .init(
            title: title,
            web: "http://www.apple.com",
            phone: ["987987987"],
            address: "Via del corso, 10",
            contact: "Mister Apple",
            description: "Description"
        )
    }
}
