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
    @State private var cameraRegionChangesFromIn = false
    @State private var shouldHideAnotationTitles = false

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
        // Сразу выставляем позицию карты из cameraRegion вместо .automatic,
        // чтобы не было фантомного auto-fit на старте, который дёргает лишнюю
        // подписку и ещё один запрос клубов.
        let initial = cameraRegion.wrappedValue
        self._location = State(initialValue: .region(
            MKCoordinateRegion(
                center: initial.center,
                span: MKCoordinateSpan(
                    latitudeDelta: initial.delta.latitude,
                    longitudeDelta: initial.delta.longitude
                )
            )
        ))
    }

    var body: some View {
        Map(position: $location) {
            UserAnnotation()
            ForEach(mapClubs, id: \.id) { clubMapData in
                Annotation("", coordinate: clubMapData.location) {
                    ClubMapAnnotation(clubMapName: clubMapData.name, shouldHideTitles: shouldHideAnotationTitles) {
                        location = .camera(.init(centerCoordinate: clubMapData.location, distance: 3000))
                        selectedClub = MapPopupData(selectedClub: clubMapData, state: .full)
                    }
                }
            }
        }
        .onChange(of: cameraRegion, { _, newValue in
            if !cameraRegionChangesFromIn {
                location = .region(.init(center: newValue.center, span: .init(latitudeDelta: newValue.delta.latitude, longitudeDelta: newValue.delta.longitude)))
            }
            cameraRegionChangesFromIn = false
        })
        .onMapCameraChange(frequency: .continuous) { (context: MapCameraUpdateContext) in
            setPopupState(.min)
            shouldHideAnotationTitles = context.region.span.latitudeDelta > 0.1
        }
        .onMapCameraChange(
            frequency: .onEnd,
            { (context: MapCameraUpdateContext) in
                setPopupState(.full)
                let region: MKCoordinateRegion = context.region
                let newRegion = CameraRegion(
                    center: region.center,
                    delta: CLLocationCoordinate2D(
                        latitude: region.span.latitudeDelta,
                        longitude: region.span.longitudeDelta
                    )
                )
                // Settle-jitter MapKit: после программного centering карта
                // обычно отдаёт чуть другие координаты (float-точность,
                // snapping). Если разница ничтожна — не пишем обратно
                // в cameraRegion, чтобы не дёрнуть лишний запрос клубов.
                if newRegion.isApproximatelyEqual(to: cameraRegion) { return }
                cameraRegionChangesFromIn = true
                self.cameraRegion = newRegion
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
