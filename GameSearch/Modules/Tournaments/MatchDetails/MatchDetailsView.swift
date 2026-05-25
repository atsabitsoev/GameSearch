//
//  MatchDetailsView.swift
//  GameSearch
//
//  Match details screen for Phase 1.C. Composition follows the
//  wireframe in `docs/tournaments/10-screens.md`:
//      Header card (caption, two teams, BoX/LIVE/score, time)
//      Maps/Games list  (only when numberOfGames > 1)
//      Streams list     (only when not finished/canceled)
//      Rosters          (only when at least one team has players)
//      Toolbar: ShareLink with deeplink to the match
//
//  TabBar is hidden via `.toolbar(.hidden, for: .tabBar)` — gives the
//  screen a "deeper" feel matching ArticleDetailsView precedent.
//

import SwiftUI

struct MatchDetailsView<ViewModel: MatchDetailsViewModelProtocol>: View {

    @StateObject private var viewModel: ViewModel
    @State private var openFailureAlertPresented: Bool = false

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            EAColor.background.ignoresSafeArea()
            content
        }
        .navigationTitle(TournamentsStrings.matchDetailsNavTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(EAColor.background, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbar { shareToolbarItem }
        .alert(
            TournamentsStrings.streamOpenFailedToast,
            isPresented: $openFailureAlertPresented
        ) {
            Button("OK", role: .cancel) {}
        }
        .task {
            await viewModel.onAppear()
        }
    }
}

// MARK: - Content

private extension MatchDetailsView {

    @ViewBuilder
    var content: some View {
        switch viewModel.state {
        case .loading:
            ScrollView {
                MatchDetailsSkeleton()
            }
            .refreshable {
                await viewModel.onPullToRefresh()
            }
        case .loaded(let match):
            loadedContent(match)
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

    func loadedContent(_ match: Match) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                MatchHeaderView(
                    match: match,
                    tournamentContext: loadedTournamentContext
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)

                MatchGamesList(match: match)

                MatchStreamsList(
                    match: match,
                    onTapStream: { stream in viewModel.onStreamTapped(stream) },
                    onStreamOpenFailed: { stream, reason in
                        viewModel.onStreamOpenFailed(stream, reason: reason)
                        openFailureAlertPresented = true
                    }
                )

                MatchRostersView(match: match)
            }
            .padding(.bottom, 24)
        }
        .refreshable {
            await viewModel.onPullToRefresh()
        }
    }

    var loadedTournamentContext: Tournament? {
        if case .loaded(let tournament) = viewModel.tournamentContext {
            return tournament
        }
        return nil
    }
}

// MARK: - Toolbar

private extension MatchDetailsView {

    @ToolbarContentBuilder
    var shareToolbarItem: some ToolbarContent {
        if case .loaded = viewModel.state, let url = viewModel.shareUrl() {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: url) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(EAColor.textPrimary)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    viewModel.onShareTapped()
                })
                .accessibilityLabel(Text(TournamentsStrings.matchShareButton))
            }
        }
    }
}
