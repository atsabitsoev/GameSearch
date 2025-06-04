//
//  LocationInfoView.swift
//  GameSearch
//
//  Created by Ацамаз on 04.06.2025.
//

import SwiftUI
import MapKit


struct LocationInfoView: View {
    let data: LocationInfoData

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(Constants.title)
                    .font(.headline)
                    .foregroundStyle(EAColor.info2)
                LocationLabel(address: data.address)
                    .font(.body)
                    .foregroundStyle(EAColor.textPrimary)
                staticMapView
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(EAColor.info1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}


private extension LocationInfoView {
    var staticMapView: some View {
        let coordinate = CLLocationCoordinate2D(latitude: data.lat, longitude: data.long)
        return Map(
            initialPosition: MapCameraPosition.region(
                MKCoordinateRegion(
                    center: coordinate,
                    latitudinalMeters: Constants.cameraDistance,
                    longitudinalMeters: Constants.cameraDistance
                )
            ),
            interactionModes: []
        ) {
            Annotation("", coordinate: coordinate) {
                ClubMapAnnotation()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(height: 200)
    }
}


private enum Constants {
    static let title: String = "Как найти"
    static let cameraDistance: Double = 150
}


#Preview(traits: .sizeThatFitsLayout) {
    LocationInfoView(
        data: LocationInfoData(
            address: "ул. Кибербезопасности, 24б",
            long: 37,
            lat: 55
        )
    )
}
