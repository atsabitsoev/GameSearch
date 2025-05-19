//
//  MapView.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 13.05.2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var location: MapCameraPosition = .automatic
    
    private let centerLocation: CLLocationCoordinate2D
    private let mapClubs: [MapClubData]
    
    init(centerLocation: CLLocationCoordinate2D? = nil, for clubs: [MapClubData]) {
        self.centerLocation = centerLocation ?? Constants.defaultCenterLocation
        self.mapClubs = clubs
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
        .onAppear {
            updateCamera()
        }
        .mapControls {
            MapUserLocationButton()
        }
    }
}


private extension MapView {
    func updateCamera() {
        if let closestClub = closestPoint(to: centerLocation, from: mapClubs.map(\.location)) {
            let region = regionThatFits(points: [centerLocation, closestClub])
            location = .region(region)
        } else {
            location = .camera(.init(centerCoordinate: centerLocation, distance: 3000))
        }
    }
    
    func closestPoint(to target: CLLocationCoordinate2D, from points: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D? {
        let targetLocation = CLLocation(latitude: target.latitude, longitude: target.longitude)
        return points.min {
            let d1 = targetLocation.distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude))
            let d2 = targetLocation.distance(from: CLLocation(latitude: $1.latitude, longitude: $1.longitude))
            return d1 < d2
        }
    }
    
    func regionThatFits(points: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        let lats = points.map(\.latitude)
        let lons = points.map(\.longitude)
        
        let minLat = lats.min() ?? 0
        let maxLat = lats.max() ?? 0
        let minLon = lons.min() ?? 0
        let maxLon = lons.max() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(maxLat - minLat, 0.01) * 1.5,
            longitudeDelta: max(maxLon - minLon, 0.01) * 1.5
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
}

private enum Constants {
    static let defaultLatitude = 55.4424
    static let defaultLongtude = 37.3636
    static let latitudinalMeters: Double = 1500
    static let longitudinalMeters: Double = 1500
    
    static let defaultCenterLocation: CLLocationCoordinate2D = .init(
        latitude: Constants.defaultLatitude,
        longitude: Constants.defaultLongtude
    )
}

#Preview {
    MapView(centerLocation: nil, for: [])
}
