//
//  CLLocationCoordinate2DExtensions.swift
//  GameSearch
//
//  Created by Ацамаз on 04.07.2025.
//

import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.latitude == rhs.latitude
        && lhs.longitude == rhs.longitude
    }
}
