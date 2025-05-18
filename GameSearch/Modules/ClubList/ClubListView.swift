//
//  ContentView.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import SwiftUI
import MapKit

struct ClubListView<ViewModel: ClubListViewModelProtocol>: View {
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel: ViewModel
    @StateObject private var locationManager = LocationManager()
    
    @FocusState private var searchFocused
    @State private var viewDidAppear = false
    @State private var mapListButtonState: MapListButtonState = .list
    
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    
    var body: some View {
        tabBar
            .onAppear {
                guard !viewDidAppear else { return }
                viewDidAppear = true
                locationManager.requestLocation()
                viewModel.onViewAppear()
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
        NavigationView {
            ZStack(alignment: .bottom) {
                MapView(centerLocation: locationManager.location, for: viewModel.mapClubs)
                    .opacity(mapListButtonState.isMap ? 1 : 0)
                
                GeometryReader { geo in
                    listView
                        .searchable(
                            text: $viewModel.searchText,
                            placement: .navigationBarDrawer(displayMode: .always),
                            prompt: "Поиск"
                        )
                        .background(Color(white: 0.1).ignoresSafeArea(.keyboard))
                        .searchFocused($searchFocused)
                        .offset(y: mapListButtonState.isMap ? geo.size.height : 0)
                        .opacity(mapListButtonState.isMap ? 0 : 1)
                        .animation(.spring(duration: 0.3), value: mapListButtonState)
                }
                VStack {
                    Spacer()
                    MapListButton(buttonState: $mapListButtonState)
                        .padding(.bottom, 16)
                }
                .ignoresSafeArea(.keyboard)
            }
            .navigationTitle("Ближайшие клубы")
            .toolbarVisibility(.visible, for: .navigationBar)
            .toolbarBackground(Color(white: 0.1), for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(white: 0.1))
        }
        .onChange(of: searchFocused) { _, newValue in
            if newValue {
                mapListButtonState = .list
            }
        }
    }
    
    var listView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.clubListCards, id: \.id) { card in
                    ClubListCell(data: card)
                        .padding(.horizontal, 16)
                        .onTapGesture {
                            viewModel.routeToDetails(clubID: card.id, router: router)
                        }
                }
            }
            .padding(.vertical, 16)
        }
    }
}

#Preview {
    ClubListView(viewModel: ClubListViewModel(interactor: ClubListInteractor()))
}
