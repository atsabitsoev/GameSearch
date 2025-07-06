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
    @State private var cameraRegionChangesFromIn = false
    
    @Binding private var cameraRegion: CameraRegion
    @Binding private var selectedClub: MapPopupData?
    
    private let centerLocation: CLLocationCoordinate2D
    private let mapClubs: [MapClubData]
    
    
    init(
        centerLocation: CLLocationCoordinate2D? = nil,
        for clubs: [MapClubData],
        selectedClub: Binding<MapPopupData?>,
        cameraRegion: Binding<CameraRegion>
    ) {
        self.centerLocation = centerLocation ?? Constants.defaultCenterLocation
        self.mapClubs = clubs
        self._selectedClub = selectedClub
        self._cameraRegion = cameraRegion
    }
    
    var body: some View {
        Map(position: $location) {
            UserAnnotation()
            ForEach(mapClubs, id: \.name) { clubMapData in
                Annotation("", coordinate: clubMapData.location) {
                    ClubMapAnnotation(clubMapName: clubMapData.name) {
                        location = .camera(.init(centerCoordinate: clubMapData.location, distance: 3000))
                        selectedClub = MapPopupData(selectedClub: clubMapData, state: .full)
                    }
                }
            }
        }
        .onChange(of: mapClubs) {
            updateCamera()
        }
        .onChange(of: cameraRegion, { _, newValue in
            if !cameraRegionChangesFromIn {
                location = .region(.init(center: newValue.center, span: .init(latitudeDelta: newValue.delta.latitude, longitudeDelta: newValue.delta.longitude)))
            }
            cameraRegionChangesFromIn = false
        })
        .onMapCameraChange(frequency: .continuous) {
            setPopupState(.min)
        }
        .onMapCameraChange(
            frequency: .onEnd,
            { (context: MapCameraUpdateContext) in
                setPopupState(.full)
                let region: MKCoordinateRegion = context.region
                let delta: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: region.span.latitudeDelta, longitude: region.span.longitudeDelta)
                cameraRegionChangesFromIn = true
                self.cameraRegion = CameraRegion(center: region.center, delta: delta)
            })
    }
}


private extension MapView {
    func setPopupState(_ state: MapPopupState) {
        if selectedClub != nil {
            withAnimation {
                selectedClub?.state = state
            }
        }
    }
    
    func updateCamera() {
        if let closestClub = closestPoint(to: centerLocation, from: mapClubs.map(\.location)) {
            let region = regionThatFits(points: [centerLocation, closestClub])
//            location = .region(region)
        } else {
//            location = .camera(.init(centerCoordinate: centerLocation, distance: 3000))
        }
    }
    
    func makeCoordinateRegion(region: CameraRegion) -> MKCoordinateRegion {
        let latMetersPerDegree = 111_000.0
        let lonMetersPerDegree = 111_320.0 * cos(region.center.latitude * .pi / 180.0)

        let deltaLatMeters = region.delta.latitude * latMetersPerDegree
        let deltaLonMeters = region.delta.longitude * lonMetersPerDegree

        return MKCoordinateRegion(center: region.center, latitudinalMeters: deltaLatMeters, longitudinalMeters: deltaLonMeters)
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
    MapView(centerLocation: nil, for: [], selectedClub: Binding<MapPopupData?>.constant(nil), cameraRegion: .constant(CameraRegion(center: CLLocationCoordinate2D(), delta: CLLocationCoordinate2D())))
}
