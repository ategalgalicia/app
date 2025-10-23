//
//  Created by Michele Restuccia on 23/10/25.
//

import SwiftUI

#if canImport(Darwin)

// MARK: Previews

@available(iOS 18, *)
#Preview {
    NavigationStack {
        HomeView(dataModel: .init())
    }
}
#endif

// MARK: HomeView

struct HomeView: View {

    @State
    var didAnimate = false
    
    var icon: CGFloat = 150

    let dataModel: HomeDataModel

    var body: some View {
        contentView
            .navigationBarTitleDisplayMode(.inline)
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
            citiesView
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .actionView {
            actionView
                .padding(.bottom, 48)
        }
    }
    
    @ViewBuilder
    private var citiesView: some View {
        ZStack {
            ForEach(0..<dataModel.cities.count, id: \.self) { index in
                let degrees = Double(index) / Double(dataModel.cities.count) * 360 - 90
                button(dataModel.cities[index], angle: .degrees(degrees), index: index)
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
    private func button(_ value: String, angle: Angle, index: Int) -> some View {
        Button {
            print(value)
        } label: {
            Text(value)
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

// MARK: Async

struct HomeViewAsync: View {
            
    var body: some View {
        AsyncView {
            HomeDataModel()
        } content: {
            HomeView(dataModel: $0)
        }
    }
}

// MARK: HomeDataModel

struct HomeDataModel {
    
    let cities: [String]
    
//    init() async throws {
//        self.cities = ["Santiago"]
//    }
    
    /// For Preview
    init() {
        self.cities = ["Santiago"]
    }
}
