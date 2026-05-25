//
//  TournamentsListView.swift
//  GameSearch
//
//  Main tab screen for the Tournaments module. Composition follows the
//  wireframe in `docs/tournaments/10-screens.md`:
//      GameSegmentControl
//      LiveMatchesStrip (hidden when empty)
//      TournamentSegmentControl
//      ScrollView of TournamentCards with infinity scroll + pull-to-refresh
//

import SwiftUI

struct TournamentsListView<ViewModel: TournamentsListViewModelProtocol>: View {

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
        .navigationTitle(TournamentsStrings.navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(EAColor.background, for: .navigationBar)
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

private extension TournamentsListView {

    @ViewBuilder
    var content: some View {
        VStack(spacing: 12) {
            controlsHeader
            mainArea
        }
    }

    var controlsHeader: some View {
        VStack(spacing: 10) {
            GameSegmentControl(selected: gameBinding)
                .padding(.horizontal, 16)
            TournamentSegmentControl(
                selected: segmentBinding,
                accentColor: GameAccentColor.color(for: viewModel.selectedGame)
            )
            .padding(.horizontal, 16)
        }
        .padding(.top, 6)
    }

    @ViewBuilder
    var mainArea: some View {
        switch viewModel.state {
        case .loading:
            scrollableSkeleton
        case .loaded(let groups):
            tournamentsScrollView(groups)
        case .empty(let kind):
            inlinePlaceholder(kind: kind, allowRefresh: true)
        case .error(let kind):
            inlinePlaceholder(kind: kind, allowRefresh: true)
        }
    }
}

// MARK: - List

private extension TournamentsListView {

    func tournamentsScrollView(_ groups: [TournamentSeriesGroup]) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if !viewModel.liveMatches.isEmpty {
                    LiveMatchesStrip(matches: viewModel.liveMatches) { match, position in
                        viewModel.onLiveMatchTapped(match, position: position)
                    }
                    .padding(.bottom, 4)
                }

                ForEach(groups) { group in
                    Button {
                        viewModel.onSeriesTapped(group)
                    } label: {
                        TournamentCard(group: group)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .onAppear {
                        viewModel.onGroupAppear(group)
                    }
                }

                if viewModel.isLoadingNextPage {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(EAColor.textSecondary)
                        .padding(.vertical, 12)
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
        .refreshable {
            await viewModel.onPullToRefresh()
        }
    }

    var scrollableSkeleton: some View {
        ScrollView {
            TournamentsSkeletonList()
                .padding(.bottom, 24)
        }
        .refreshable {
            await viewModel.onPullToRefresh()
        }
    }

    func inlinePlaceholder(
        kind: TournamentsEmptyStateView.Kind,
        allowRefresh: Bool
    ) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                if !viewModel.liveMatches.isEmpty {
                    LiveMatchesStrip(matches: viewModel.liveMatches) { match, position in
                        viewModel.onLiveMatchTapped(match, position: position)
                    }
                    .padding(.bottom, 4)
                }
                TournamentsEmptyStateView(kind: kind) {
                    Task { await viewModel.onRetry() }
                }
                .padding(.top, 32)
            }
        }
        .refreshable {
            if allowRefresh {
                await viewModel.onPullToRefresh()
            }
        }
    }
}

// MARK: - Bindings

private extension TournamentsListView {
    var gameBinding: Binding<Game> {
        Binding(
            get: { viewModel.selectedGame },
            set: { viewModel.onSelectGame($0) }
        )
    }

    var segmentBinding: Binding<TournamentSegment> {
        Binding(
            get: { viewModel.selectedSegment },
            set: { viewModel.onSelectSegment($0) }
        )
    }
}
