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
        let address: String
    }
    
    @State
    var mapPosition: MapCameraPosition
        
    init(place: Item) {
        self.places = [place]
        _mapPosition = State(initialValue: .region(.init(
            center: place.coordinate,
            span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )))
    }
    
    var body: some View {
        contentView
    }

    @ViewBuilder
    private var contentView: some View {
        #if canImport(Darwin)
        Map(position: $mapPosition) {
            ForEach(places) {
                Marker($0.address, coordinate: $0.coordinate)
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
            address: address
        )
    }
}

private extension MapView.Item {
    
    var coordinate: CLLocationCoordinate2D {
        .init(
            latitude: latitude,
            longitude: longitude
        )
    }
}
