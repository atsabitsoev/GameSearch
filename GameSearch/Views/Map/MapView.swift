//
//  MapView.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 13.05.2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var location: MapCameraPosition
    
    private let defaultCenterLocation: CLLocationCoordinate2D = .init(
        latitude: Constants.defaultLatitude,
        longitude: Constants.defaultLongtude
    )
    private let centerLocation: CLLocationCoordinate2D
    private let mapClubs: [MapClubData]
    
    init(centerLocation: CLLocationCoordinate2D? = nil, for clubs: [MapClubData]) {
        self.centerLocation = centerLocation ?? defaultCenterLocation
        self.mapClubs = clubs
        self.location = .userLocation(fallback: .automatic)
    }
    
    var body: some View {
        Map(position: $location) {
            UserAnnotation()
            ForEach(mapClubs, id: \.name) { clubMapData in
                Annotation("", coordinate: clubMapData.location) {
                    ClubMapAnnotation(clubMapName: clubMapData.name) {
                        location = .camera(.init(centerCoordinate: clubMapData.location, distance: 3000))
                    }
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
        }
    }
}

private enum Constants {
    static let defaultLatitude = 55.4424
    static let defaultLongtude = 37.3636
    static let latitudinalMeters: Double = 1500
    static let longitudinalMeters: Double = 1500
}

#Preview {
    MapView(centerLocation: nil, for: [])
}
