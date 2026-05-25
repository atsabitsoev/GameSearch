//
//  TournamentDetailsView.swift
//  GameSearch
//
//  Tournament details screen for Phase 1.B. Composition matches the
//  wireframe in `docs/tournaments/10-screens.md`:
//      Header card (logo, title, dates, country, prizepool, tier)
//      4-tab picker (Матчи / Таблица / Сетка / Команды)
//      Tab content (lazy-loaded for Standings only)
//      Toolbar: ShareLink with deeplink to this tournament
//

import SwiftUI

struct TournamentDetailsView<ViewModel: TournamentDetailsViewModelProtocol>: View {

    // MARK: - Observed

    @StateObject private var viewModel: ViewModel
    @EnvironmentObject private var router: TournamentsRouter

    // MARK: - Init

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            EAColor.background.ignoresSafeArea()
            content
        }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(EAColor.background, for: .navigationBar)
        .toolbar { shareToolbarItem }
        .onAppear {
            viewModel.setRouteHandler { [weak router] route in
                router?.push(route)
            }
        }
        .onDisappear {
            viewModel.setRouteHandler(nil)
        }
        .task {
            await viewModel.onAppear()
        }
    }
}

// MARK: - Content

private extension TournamentDetailsView {

    @ViewBuilder
    var content: some View {
        switch viewModel.state {
        case .loading:
            ScrollView {
                TournamentDetailsSkeleton()
            }
            .refreshable {
                await viewModel.onPullToRefresh()
            }
        case .loaded(let tournament):
            loadedContent(tournament)
        case .error(let kind):
            ScrollView {
                TournamentsEmptyStateView(kind: kind) {
                    Task { await viewModel.onRetry() }
                }
                .padding(.top, 32)
            }
            .refreshable {
                await viewModel.onPullToRefresh()
            }
        }
    }

    func loadedContent(_ tournament: Tournament) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                TournamentHeaderView(tournament: tournament)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                stagePicker(activeStage: tournament)

                TournamentTabPicker(
                    selected: tabBinding,
                    accentColor: GameAccentColor.color(for: tournament.game)
                )
                .padding(.horizontal, 16)

                tabContent(tournament)
            }
            .padding(.bottom, 24)
        }
        .refreshable {
            await viewModel.onPullToRefresh()
        }
    }

    @ViewBuilder
    func stagePicker(activeStage: Tournament) -> some View {
        if case .loaded(let stages) = viewModel.stagesState, stages.count > 1 {
            TournamentStagePicker(
                stages: stages,
                selectedStageId: activeStage.id,
                accentColor: GameAccentColor.color(for: activeStage.game),
                onSelect: { stage in viewModel.onSelectStage(stage) }
            )
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    func tabContent(_ tournament: Tournament) -> some View {
        switch viewModel.selectedTab {
        case .matches:
            MatchesTab(
                state: viewModel.matchesState,
                stageName: tournament.name,
                onTapMatch: { match in viewModel.onTapMatch(match) },
                onRetry: { Task { await viewModel.onMatchesRetry() } }
            )
        case .standings:
            StandingsTab(state: viewModel.standingsState) {
                Task { await viewModel.onStandingsRetry() }
            }
        case .brackets:
            BracketsTab()
        case .participants:
            ParticipantsTab(tournament: tournament)
        }
    }
}

// MARK: - Toolbar

private extension TournamentDetailsView {

    @ToolbarContentBuilder
    var shareToolbarItem: some ToolbarContent {
        if case .loaded(let tournament) = viewModel.state,
           let url = shareUrl(for: tournament) {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: url) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(EAColor.textPrimary)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    viewModel.onShareTapped()
                })
                .accessibilityLabel(Text(TournamentsStrings.tournamentShareButton))
            }
        }
    }

    func shareUrl(for tournament: Tournament) -> URL? {
        let target = tournament.slug.isEmpty ? String(tournament.id) : tournament.slug
        return URL(string: "gamesearch://tournament/\(target)")
    }
}

// MARK: - Helpers

private extension TournamentDetailsView {

    var navTitle: String {
        if case .loaded(let tournament) = viewModel.state {
            let trimmed = tournament.displayListTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? TournamentsStrings.tournamentDetailsNavTitleFallback : trimmed
        }
        return TournamentsStrings.tournamentDetailsNavTitleFallback
    }

    var tabBinding: Binding<TournamentDetailsTab> {
        Binding(
            get: { viewModel.selectedTab },
            set: { viewModel.onSelectTab($0) }
        )
    }
}
