//
//  CameraRegion.swift
//  GameSearch
//
//  Created by Ацамаз on 04.07.2025.
//

import CoreLocation

struct CameraRegion: Equatable {
    let center: CLLocationCoordinate2D
    let delta: CLLocationCoordinate2D
}

extension CameraRegion {
    // Порог «значимого» смещения центра карты, метров.
    static let approxEqualCenterMeters: CLLocationDistance = 50
    // Порог «значимого» изменения зума, относительный (20%).
    // MapKit после программного centering всегда подгоняет один из delta
    // под аспект экрана и возвращает регион «шире» запроса (~15% по нашему
    // случаю). 20% — это плата за то, чтобы такие aspect-fit echo не
    // считались реальным изменением зума.
    static let approxEqualZoomRatio: Double = 0.20

    /// Считает регионы «практически одинаковыми», если центр сместился
    /// меньше, чем на ~50 м, и каждая из сторон зума поменялась меньше,
    /// чем на 20%. Используется в `removeDuplicates` пайплайна загрузки
    /// клубов, чтобы микро-апдейты карты не дёргали повторные запросы.
    func isApproximatelyEqual(to other: CameraRegion) -> Bool {
        let centerA = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let centerB = CLLocation(latitude: other.center.latitude, longitude: other.center.longitude)
        guard centerA.distance(from: centerB) < Self.approxEqualCenterMeters else { return false }

        let latRatio = Self.relativeDiff(delta.latitude, other.delta.latitude)
        let lngRatio = Self.relativeDiff(delta.longitude, other.delta.longitude)
        return latRatio < Self.approxEqualZoomRatio && lngRatio < Self.approxEqualZoomRatio
    }

    private static func relativeDiff(_ a: Double, _ b: Double) -> Double {
        let avg = (a + b) / 2
        guard avg > 0 else { return 0 }
        return abs(a - b) / avg
    }
}
