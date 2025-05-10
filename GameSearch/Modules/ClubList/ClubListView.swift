//
//  ContentView.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import SwiftUI
import MapKit

fileprivate final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
}


fileprivate struct MapListButtonData {
    let title: String
    let systemImage: String
}


fileprivate enum MapListButtonState {
    case map
    case list
    
    var mapListButtonData: MapListButtonData {
        switch self {
        case .map: return MapListButtonData(title: "Список", systemImage: "list.bullet")
        case .list: return MapListButtonData(title: "Карта", systemImage: "map")
        }
    }
    
    
    mutating func toggle() {
        switch self {
        case .map:
            self = .list
        case .list:
            self = .map
        }
    }
}


struct ClubListView<ViewModel: ClubListViewModelProtocol>: View {
    @State private var searchText = ""
    @State private var mapListButtonState: MapListButtonState = .list
    
    @ObservedObject private(set) var viewModel: ViewModel
    @StateObject private var locationManager = LocationManager()
    
    
    
    var body: some View {
        tabBar
            .onAppear {
                locationManager.requestLocation()
            }
    }
    
    var navigationView: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if mapListButtonState == .list {
                    listView
                        .searchable(
                            text: $searchText,
                            placement: .navigationBarDrawer(
                                displayMode: .always
                            ),
                            prompt: "Поиск"
                        )
                        .transition(.move(edge: .bottom))
                        .animation(.default, value: mapListButtonState)
                } else {
                    mapView
                }
                mapListButton
                    .padding(.bottom, 16)
            }
            .onChange(of: searchText, { _, newValue in
                viewModel.searchTextChanged(newValue)
            })
            .navigationTitle("Ближайшие клубы")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var mapListButton: some View {
        Button {
            withAnimation {
                mapListButtonState.toggle()
            }
        } label: {
            Label(
                mapListButtonState.mapListButtonData.title,
                systemImage: mapListButtonState.mapListButtonData.systemImage
            )
            .padding()
            .background(.white)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 24,
                    style: .circular
                )
            )
        }
        .buttonStyle(.automatic)
    }
    
    var tabBar: some View {
        TabView {
            Tab("Клубы", systemImage: "house") {
                navigationView
            }
            Tab("Карта", systemImage: "map") {
                Text("Тут был геннадий")
            }
        }
        .tint(Color.purple)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    @ViewBuilder
    var mapView: some View {
        if let location = locationManager.location {
            Map(
                position: Binding<MapCameraPosition>.constant(
                    MapCameraPosition.region(
                        MKCoordinateRegion.init(
                            center: location,
                            latitudinalMeters: 1500,
                            longitudinalMeters: 1500
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
        } else {
            Map()
        }
    }
    
    var listView: some View {
        ScrollView {
            ForEach(viewModel.clubs, id: \.name) { club in
                LazyVStack(alignment: .leading) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .circular)
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .bottomTrailing, endPoint: .topLeading))
                            .frame(height: 160)
                        Text("\(club.name)")
                        
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    ClubListView(viewModel: ClubListViewModel())
}
