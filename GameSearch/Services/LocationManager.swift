//
//  LocationManager.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 13.05.2025.
//

import MapKit

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    private var locationGot = false
    var onLocationGot: () -> () = {}
    var onLocationChange: () -> () = {}
    
    @Published var location: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    func requestLocation() {
        self.manager.requestWhenInUseAuthorization()
        self.manager.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        if !locationGot {
            onLocationGot()
            locationGot = true
        } else {
            onLocationChange()
        }
    }
}
