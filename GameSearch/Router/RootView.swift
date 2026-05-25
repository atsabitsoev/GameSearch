//
//  RootView.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//

import SwiftUI
import AnalyticsModule

struct RootView<Factory: ScreenFactoryProtocol>: View {
    @AppStorage("has_seen_welcome_view") private var hasSeenWelcomeView = false
    @EnvironmentObject private var clubsRouter: ClubsRouter
    @EnvironmentObject private var articlesRouter: ArticlesRouter
    @EnvironmentObject private var tournamentsRouter: TournamentsRouter

    @State private var currentTab: TabTag = .news
    @State private var isWelcomeViewPresented = false

    private let factory: Factory
    
    
    init(factory: Factory) {
        self.factory = factory
    }
    

    var body: some View {
        TabView(selection: $currentTab) {
            Tab("Новости", systemImage: "newspaper", value: .news) {
                NavigationStack(path: $articlesRouter.path) {
                    factory.makeArticlesListView()
                        .environmentObject(articlesRouter)
                        .navigationDestination(for: ArticlesRoute.self) { route in
                            switch route {
                            case .detailsByArticle(let data):
                                factory.makeArticleDetailsView(data: .article(data))
                            case .detailsBySlug(let slug):
                                factory.makeArticleDetailsView(data: .slug(slug))
                            }
                        }
                }
            }
            Tab("Клубы", systemImage: "cube", value: .clubs) {
                NavigationStack(path: $clubsRouter.path) {
                    factory.makeClubListView()
                        .environmentObject(clubsRouter)
                        .navigationDestination(for: ClubsRoute.self) { route in
                            switch route {
                            case .details(let data):
                                factory.makeClubDetailsView(data)
                            }
                        }
                        .enableSwipeBack()
                }
                .setupClubsNavigationBarAppearance()
            }
            Tab("Турниры", systemImage: "trophy", value: .tournaments) {
                NavigationStack(path: $tournamentsRouter.path) {
                    factory.makeTournamentsView()
                        .environmentObject(tournamentsRouter)
                        .navigationDestination(for: TournamentsRoute.self) { route in
                            switch route {
                            case .tournamentDetails(let idOrSlug):
                                factory.makeTournamentDetailsView(idOrSlug: idOrSlug)
                            case .matchDetails(let id):
                                factory.makeMatchDetailsView(id: id)
                            }
                        }
                }
            }
        }
        .tint(EAColor.accent)
        .setupTabBarAppearance()
        .onAppear {
            isWelcomeViewPresented = !hasSeenWelcomeView
            sendTabAnalytics(for: currentTab)
        }
        .onChange(of: currentTab) { _, newTab in
            sendTabAnalytics(for: newTab)
        }
        .onOpenURL { url in
            handleUrl(url)
        }
        .fullScreenCover(isPresented: $isWelcomeViewPresented) {
            WelcomeView(
                onContinue: onWelcomeContinue
            ) { destination in
                onWelcomeDestination(destination)
            }
            .onAppear {
              hasSeenWelcomeView = true
              sendWelcomeShownAnalytics()
            }
        }
    }

    func handleUrl(_ url: URL) {
        let deepLink = Deeplink(from: url)
        switch deepLink {
        case .articles(let slug):
            isWelcomeViewPresented = false
            currentTab = .news
            if let slug {
                articlesRouter.push(.detailsBySlug(slug))
            } else {
                articlesRouter.reset()
            }
            sendDeeplinkAnalytics(url, slug: slug)
        case .tournamentsTab(let game):
            isWelcomeViewPresented = false
            currentTab = .tournaments
            tournamentsRouter.reset()
            // `gamesearch://tournaments/<game>` opens the tab AND preselects
            // the game segment (cs2 / dota2). Without this, the tab would
            // open with whatever game was last selected, contradicting the
            // contract documented in `docs/tournaments/14-deeplinks.md`.
            if let game {
                tournamentsRouter.preselectedGame = game
            }
            sendTournamentsDeeplinkAnalytics(url, kind: "tab", value: game?.rawValue)
        case .tournamentDetails(let idOrSlug):
            isWelcomeViewPresented = false
            currentTab = .tournaments
            tournamentsRouter.push(.tournamentDetails(idOrSlug: idOrSlug))
            sendTournamentsDeeplinkAnalytics(url, kind: "tournament", value: idOrSlug)
        case .matchDetails(let id):
            isWelcomeViewPresented = false
            currentTab = .tournaments
            tournamentsRouter.push(.matchDetails(id: id))
            sendTournamentsDeeplinkAnalytics(url, kind: "match", value: String(id))
        case nil:
            return
        }
    }

    func onWelcomeDestination(_ destination: WelcomeDestination) {
        switch destination {
        case .clubs:
            currentTab = .clubs
        case .news:
            currentTab = .news
        case .tournaments:
            currentTab = .tournaments
        }
        isWelcomeViewPresented = false

        sendWelcomeOptionAnalytics(destination)
    }

    func onWelcomeContinue() {
        isWelcomeViewPresented = false
        AppMetricaReporter.reportEvent("welcome_continue_tap")
    }
}


private extension RootView {
    func sendDeeplinkAnalytics(_ url: URL, slug: String?) {
        var deeplinkParams: [String: Any] = ["path": url.path]
        if let slug {
            deeplinkParams["article_slug"] = slug
        }

        AppMetricaReporter.reportEvent("deeplink_open", parameters: deeplinkParams)
    }

    func sendTournamentsDeeplinkAnalytics(_ url: URL, kind: String, value: String? = nil) {
        var params: [String: Any] = ["path": url.path, "kind": kind]
        if let value {
            params["value"] = value
        }
        AppMetricaReporter.reportEvent("deeplink_open", parameters: params)
    }

    func sendTabAnalytics(for tab: TabTag) {
        switch tab {
        case .news:
            AppMetricaReporter.reportEvent("tab_news")
        case .clubs:
            AppMetricaReporter.reportEvent("tab_clubs")
        case .tournaments:
            AppMetricaReporter.reportEvent("tab_tournaments")
        }
    }

    func sendWelcomeOptionAnalytics(_ destination: WelcomeDestination) {
        AppMetricaReporter.reportEvent(
            "welcome_option_tap",
            parameters: [
                "option": destination.rawValue
            ]
        )
    }

    func sendWelcomeShownAnalytics() {
        AppMetricaReporter.reportEvent("welcome_screen_shown")
    }
}
