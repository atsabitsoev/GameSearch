//
//  LocationManager.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 13.05.2025.
//

import MapKit

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    // Минимальное смещение между двумя «значимыми» апдейтами локации.
    // Глушит шум симулятора (City Run / Bicycle Ride и пр.) и экономит
    // батарею на реальном устройстве — для поиска клубов 50 м более чем достаточно.
    private static let significantDistanceMeters: CLLocationDistance = 50
    private static let maxLocationAgeSeconds: TimeInterval = 30

    private var locationGot = false
    private var didStartUpdating = false
    private var lastReportedLocation: CLLocation?

    var onLocationGot: () -> () = {}
    var onLocationChange: () -> () = {}
    @Published var locationAllowed: Bool = false

    @Published var location: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = Self.significantDistanceMeters
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        startUpdatesIfNeeded()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last, isValid(newLocation) else { return }

        // Дополнительная защита поверх distanceFilter: симулятор/iOS иногда
        // присылают повторную ту же координату, либо «прыгают» на 1–2 метра.
        if let last = lastReportedLocation,
           newLocation.distance(from: last) < Self.significantDistanceMeters {
            return
        }

        lastReportedLocation = newLocation
        location = newLocation.coordinate

        if !locationGot {
            locationGot = true
            onLocationGot()
        } else {
            onLocationChange()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.locationAllowed = status.rawValue > 2
            if self.locationAllowed {
                self.startUpdatesIfNeeded()
            }
        }
    }
}

private extension LocationManager {
    func startUpdatesIfNeeded() {
        guard !didStartUpdating else { return }
        didStartUpdating = true
        manager.startUpdatingLocation()
    }

    func isValid(_ location: CLLocation) -> Bool {
        guard location.horizontalAccuracy >= 0 else { return false }
        let age = -location.timestamp.timeIntervalSinceNow
        return age < Self.maxLocationAgeSeconds
    }
}
