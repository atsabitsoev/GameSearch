//
//  MapView.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 13.05.2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    private let defaultCenterLocation: CLLocationCoordinate2D = .init(
        latitude: Constants.defaultLatitude,
        longitude: Constants.defaultLongtude
    )
    private let centerLocation: CLLocationCoordinate2D
    
    init(centerLocation: CLLocationCoordinate2D? = nil) {
        self.centerLocation = centerLocation ?? defaultCenterLocation
    }
    
    var body: some View {
        Map(
            position: Binding<MapCameraPosition>.constant(
                MapCameraPosition.region(
                    MKCoordinateRegion.init(
                        center: centerLocation,
                        latitudinalMeters: Constants.latitudinalMeters,
                        longitudinalMeters: Constants.longitudinalMeters
                    )
                )
            ),
            bounds: nil,
            interactionModes: .all,
            scope: nil,
            content: {
                UserAnnotation()
            }
        )
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
    MapView(centerLocation: nil)
}
