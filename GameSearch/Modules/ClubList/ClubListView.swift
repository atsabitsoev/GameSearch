import SwiftUI
import MapKit

struct ClubListView<ViewModel: ClubListViewModelProtocol>: View {
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel: ViewModel
    @StateObject private var locationManager = LocationManager()

    @FocusState private var searchFocused
    @State private var searchActive = false
    @State private var viewDidAppear = false
    @State private var mapListButtonState: MapListButtonState = .list


    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            contentView
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(EAColor.background, for: .navigationBar)
                .toolbarVisibility(.visible, for: .navigationBar)
                .toolbarVisibility(.visible, for: .tabBar)
                .toolbarBackground(EAColor.background, for: .tabBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Ближайшие клубы")
                            .font(EAFont.navigationBarTitle)
                            .foregroundStyle(EAColor.textPrimary)
                    }
                }
        }
    }
}


private extension ClubListView {
    var contentView: some View {
        ZStack(alignment: .bottom) {
            mapView
            GeometryReader { listView($0) }
            mapListButton
            mapPopupView
        }
        .background(EAColor.background)
        .onAppear {
            guard !viewDidAppear else { return }
            viewDidAppear = true
            locationManager.requestLocation()
            viewModel.onViewAppear()
        }
        .onChange(of: searchFocused) { _, isFocused in
            if isFocused, mapListButtonState == .map {
                withAnimation(.spring(duration: 0.3)) {
                    viewModel.clearMapPopupClub()
                    mapListButtonState = .list
                }
            }
            if !isFocused, viewModel.mapPopupClub != nil {
                withAnimation(.spring(duration: 0.3)) {
                    viewModel.clearMapPopupClub()
                }
            }
        }
    }

    var mapView: some View {
        MapView(
            centerLocation: locationManager.location,
            for: viewModel.mapClubs,
            selectedClub: $viewModel.mapPopupClub
        )
        .opacity(mapListButtonState.isMap ? 1 : 0)
    }
    
    @ViewBuilder
    var mapPopupView: some View {
        if let mapPopupClub = viewModel.mapPopupClub, mapListButtonState.isMap {
            MapPopup(
                data: mapPopupClub,
                onTap: {
                    viewModel.routeToDetails(clubID: mapPopupClub.selectedClub.id, router: router)
                },
                onDismiss: {
                    viewModel.clearMapPopupClub()
                }
            )
            .padding(.bottom, 32)
            .transition(.move(edge: .bottom))
            .animation(.spring(), value: mapPopupClub)
        }
    }

    var mapListButton: some View {
        VStack {
            Spacer()
            MapListButton(buttonState: $mapListButtonState)
                .padding(.bottom, 16)
        }
        .ignoresSafeArea(.keyboard)
    }


    func listView(_ geo: GeometryProxy) -> some View {
        List(viewModel.clubListCards, id: \.id) { card in
            clubListCell(card)
        }
        .background(EAColor.background.ignoresSafeArea(.keyboard))
        .offset(y: mapListButtonState.isMap ? geo.size.height : 0)
        .opacity(mapListButtonState.isMap ? 0 : 1)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .searchable(
            text: $viewModel.searchText,
            isPresented: $searchActive,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Поиск"
        )
        .searchFocused($searchFocused)
        .ignoresSafeArea(.keyboard)
        .onScrollPhaseChange { _, newPhase in
            if newPhase == .interacting {
                if viewModel.searchText.isEmpty {
                    searchActive = false
                } else {
                    searchFocused = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
    }

    func clubListCell(_ card: ClubListCardData) -> some View {
        ClubListCell(data: card)
            .listRowSeparator(.hidden)
            .listRowBackground(EAColor.background)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .onTapGesture {
                viewModel.routeToDetails(clubID: card.id, router: router)
            }
    }
}


#Preview {
    ClubListView(viewModel: ClubListViewModel(interactor: ClubListInteractor()))
}
