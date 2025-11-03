import SwiftUI
import MapKit

struct ClubListView<ViewModel: ClubListViewModelProtocol>: View {
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel: ViewModel
    
    @FocusState private var searchFocused
    @State private var searchActive = false
    @State private var viewDidAppear = false
    
    @State private var selectedDetent: PresentationDetent = .height(200)
    
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            contentView
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: { navBarContent })
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
                .sheet(isPresented: $viewModel.showFiltersView) {
                    ZStack {
                        EAColor.background
                            .padding(.bottom, -200)
                        FiltersView(
                            isPresented: $viewModel.showFiltersView,
                            selectedDetent: $selectedDetent,
                            initialFilters: viewModel.filtersManager.filters
                        ) { newFilters in
                            viewModel.onFiltersApply(newFilters)
                        }
                        .presentationDetents([.height(236), .height(370)], selection: $selectedDetent)
                        .presentationDragIndicator(.visible)
                        .presentationBackground(EAColor.background)
                    }
                }
        }
    }
}


private extension ClubListView {
    var contentView: some View {
        ZStack(alignment: .bottom) {
            mapView
            GeometryReader { scrollClubView($0) }
            HStack {
                mapListButton
                geoButton
            }
            mapPopupView
            loadingLine
        }
        .background(EAColor.background)
        .onAppear {
            guard !viewDidAppear else { return }
            viewDidAppear = true
            viewModel.locationManager.requestLocation()
            viewModel.onViewAppear()
        }
        .onChange(of: searchFocused) { _, isFocused in
            if isFocused && viewModel.mapListButtonState.isMap {
                withAnimation(.spring(duration: 0.3)) {
                    viewModel.clearMapPopupClub()
                    viewModel.mapListButtonState = .list
                }
            }
            if !isFocused, viewModel.mapPopupClub != nil {
                withAnimation(.spring(duration: 0.3)) {
                    viewModel.clearMapPopupClub()
                }
            }
        }
    }
    
    var navBarContent: some ToolbarContent {
        ToolbarItem {
            Button {
                DispatchQueue.main.async {
                    viewModel.showFiltersView = true
                }
            } label: {
                Image(systemName: viewModel.filtersManager.filtersApplied ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
            }

        }
    }
    
    var loadingLine: some View {
        VStack {
            RoundedRectangle(cornerRadius: 1)
                .frame(maxWidth: viewModel.isLoading ? 0 : .infinity, maxHeight: 2)
                .opacity(viewModel.isLoading ? 1 : 0)
                .foregroundStyle(EAColor.accent)
                .animation(.easeInOut, value: viewModel.isLoading)
            Spacer()
        }
    }

    var mapView: some View {
        MapView(
            centerLocation: viewModel.locationManager.location,
            for: viewModel.mapClubs,
            selectedClub: $viewModel.mapPopupClub,
            cameraRegion: $viewModel.cameraRegion
        )
        .opacity(viewModel.mapListButtonState.isMap ? 1 : 0)
    }
    
    @ViewBuilder
    var mapPopupView: some View {
        if let mapPopupClub = viewModel.mapPopupClub, viewModel.mapListButtonState.isMap {
            MapPopup(
                data: mapPopupClub,
                onTap: {
                    viewModel.routeToDetails(clubID: mapPopupClub.selectedClub.id, router: router)
                },
                onDismiss: {
                    viewModel.clearMapPopupClub()
                }
            )
            .padding(.bottom, 16)
            .transition(.move(edge: .bottom))
            .animation(.spring(), value: mapPopupClub)
        }
    }

    var mapListButton: some View {
        VStack {
            Spacer()
            MapListButton(buttonState: $viewModel.mapListButtonState)
                .padding(.bottom, 16)
        }
        .ignoresSafeArea(.keyboard)
    }
    
    @ViewBuilder
    var geoButton: some View {
        if !viewModel.geoApplied {
            VStack {
                Spacer()
                Button {
                    viewModel.onGeoButtonTap()
                } label: {
                    Image(systemName: "location")
                        .fontWeight(.bold)
                        .padding()
                        .background(.white)
                        .clipShape(
                            Circle()
                        )
                }
                .padding(.bottom, 16)
            }
            .ignoresSafeArea(.keyboard)
        }
    }


    func scrollClubView(_ geo: GeometryProxy) -> some View {
        ScrollView {
            clubListContent
        }
        .background(EAColor.background.ignoresSafeArea(.keyboard))
        .offset(y: viewModel.mapListButtonState.isMap ? geo.size.height : 0)
        .opacity(viewModel.mapListButtonState.isMap ? 0 : 1)
        .searchable(
            text: $viewModel.searchText,
            isPresented: $searchActive,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Поиск"
        )
        .searchPresentationToolbarBehavior(.avoidHidingContent)
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
    
    @ViewBuilder
    var clubListContent: some View {
        if viewModel.clubListCards.isEmpty {
            emptyListView
        } else {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.clubListCards, id: \.id) { card in
                    clubListCell(card)
                }
            }
        }
    }
    
    var emptyListView: some View {
        EmptyListView(
            title: "Здесь пока пусто",
            subtitle: "Попробуйте изменить фильтры или расширить радиус поиска",
            isLoading: viewModel.isLoading
        )
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
        .padding(.horizontal, 16)
    }
    

    func clubListCell(_ card: ClubListCardData) -> some View {
        ClubListCell(data: card)
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .background(EAColor.background)
            .onTapGesture {
                viewModel.routeToDetails(clubID: card.id, router: router)
            }
    }
}


#Preview {
    ClubListView(viewModel: ClubListViewModel(interactor: ClubListInteractor()))
}
