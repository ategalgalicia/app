//
//  Created by Michele Restuccia on 5/12/25.
//

import SwiftUI
import AtegalCore

#if canImport(Darwin)
import MapKit
#endif

struct MapView: View {
    
    let places: [Item]
    struct Item: Identifiable {
        let id: UUID
        let latitude: Double
        let longitude: Double
        let title: String
        let subtitle: String?
    }
        
    init(places: [Item]) {
        self.places = places
    }
    
    var body: some View {
        contentView
    }

    @ViewBuilder
    private var contentView: some View {
        #if canImport(Darwin)
        Map {
            ForEach(places) { point in
                Annotation(
                    point.title,
                    coordinate: .init(
                        latitude: point.latitude,
                        longitude: point.longitude
                    )
                ) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                }
            }
        }
        .mapStyle(.standard)
        .allowsHitTesting(false)
        #else
        ComposeView {
            MapComposer(
                latitudes: places.map(\.latitude),
                longitudes: places.map(\.longitude),
                titles: places.map(\.title),
                subtitles: places.map { $0.subtitle ?? "" }
            )
        }
        #endif
    }
}

#if SKIP
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.Marker
import com.google.maps.android.compose.MarkerState
import com.google.maps.android.compose.rememberCameraPositionState
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.MapUiSettings

struct MapComposer: ContentComposer {

    let latitudes: [Double]
    let longitudes: [Double]
    let titles: [String]
    let subtitles: [String]

    @Composable
    func Compose(context: ComposeContext) {
        let defaultLat = latitudes.first ?? 42.8764
        let defaultLng = longitudes.first ?? -8.5455

        GoogleMap(
            cameraPositionState: rememberCameraPositionState {
                position = CameraPosition.fromLatLngZoom(
                    LatLng(defaultLat, defaultLng),
                    Float(7.0)
                )
            },
            uiSettings = MapUiSettings(
                scrollGesturesEnabled = false,
                zoomGesturesEnabled = true
            )
        ) {
            for i in latitudes.indices {
                Marker(
                    state: MarkerState(
                        position: LatLng(latitudes[i], longitudes[i])
                    ),
                    title: titles[i],
                    snippet: subtitles[i]
                )
            }
        }
    }
}
#endif

extension Center {
    
    var place: MapView.Item {
        .init(
            id: UUID(),
            latitude: latitude,
            longitude: longitude,
            title: city,
            subtitle: address
        )
    }
}
