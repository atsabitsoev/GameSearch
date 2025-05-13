//
//  ContentView.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import SwiftUI
import MapKit

struct ClubListView<ViewModel: ClubListViewModelProtocol>: View {
    @ObservedObject private(set) var viewModel: ViewModel
    @StateObject private var locationManager = LocationManager()
    
    @State private var searchText = ""
    @State private var mapListButtonState: MapListButtonState = .list
    
    
    var body: some View {
        tabBar
            .onAppear {
                locationManager.requestLocation()
            }
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
        .setupTabBarAppearance()
    }
    
    var navigationView: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                MapView(centerLocation: locationManager.location)
                    .opacity(mapListButtonState.isMap ? 1 : 0)
                GeometryReader { geo in
                    listView
                        .searchable(
                            text: $searchText,
                            placement: .navigationBarDrawer(
                                displayMode: .always
                            ),
                            prompt: "Поиск"
                        )
                        .offset(y: mapListButtonState.isMap ? geo.size.height : 0)
                        .opacity(mapListButtonState.isMap ? 0 : 1)
                        .animation(.spring, value: mapListButtonState)
                }
                MapListButton(buttonState: $mapListButtonState)
                    .padding(.bottom, 16)
            }
            .toolbarVisibility(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .onChange(of: searchText, { _, newValue in
                viewModel.searchTextChanged(newValue)
            })
            .navigationTitle("Ближайшие клубы")
            .navigationBarTitleDisplayMode(.inline)
        }
        .toolbarVisibility(.visible, for: .tabBar)
        .toolbarBackground(Color(.systemBackground), for: .tabBar)
        .setupNavigationBarAppearance()
    }
    
    var listView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.clubs, id: \.name) { club in
                    ClubListCell(club: club)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 16)
        }
    }
}

#Preview {
    ClubListView(viewModel: ClubListViewModel())
}
