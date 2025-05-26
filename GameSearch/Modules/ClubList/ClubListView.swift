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
            ZStack(alignment: .bottom) {
                mapView
                GeometryReader { geo in
                    listView
                        .offset(y: mapListButtonState.isMap ? geo.size.height : 0)
                        .opacity(mapListButtonState.isMap ? 0 : 1)
                }

                VStack {
                    Spacer()
                    MapListButton(buttonState: $mapListButtonState)
                        .padding(.bottom, 16)
                }
                .ignoresSafeArea(.keyboard)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(EAColor.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Ближайшие клубы")
                        .font(EAFont.navigationBarTitle)
                        .foregroundStyle(EAColor.textPrimary)
                }
            }
            .toolbarVisibility(.visible, for: .navigationBar)
            .toolbarVisibility(.visible, for: .tabBar)
            .toolbarBackground(EAColor.background, for: .tabBar)
            .background(EAColor.background)
            .onAppear {
                guard !viewDidAppear else { return }
                viewDidAppear = true
                locationManager.requestLocation()
                viewModel.onViewAppear()
            }
            .onChange(of: searchFocused) { _, newValue in
                if newValue && mapListButtonState == .map {
                    withAnimation(.spring(duration: 0.3)) {
                        mapListButtonState = .list
                    }
                }
            }
        }
    }

    private var listView: some View {
        List(viewModel.clubListCards, id: \.id) { card in
            ClubListCell(data: card)
                .listRowSeparator(.hidden)
                .listRowBackground(EAColor.background)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .onTapGesture {
                    viewModel.routeToDetails(clubID: card.id, router: router)
                }
        }
        .background(EAColor.background.ignoresSafeArea(.keyboard))
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

    private var mapView: some View {
        MapView(centerLocation: locationManager.location, for: viewModel.mapClubs)
            .opacity(mapListButtonState.isMap ? 1 : 0)
    }
}

#Preview {
    ClubListView(viewModel: ClubListViewModel(interactor: ClubListInteractor()))
}
