//
//  RootView.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//

import SwiftUI


struct RootView<Factory: ScreenFactoryProtocol>: View {
    @AppStorage("has_seen_welcome_view") private var hasSeenWelcomeView = false
    @EnvironmentObject private var clubsRouter: ClubsRouter
    @EnvironmentObject private var articlesRouter: ArticlesRouter

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
                NavigationStack {
                    factory.makeTournamentsView()
                }
            }
        }
        .tint(EAColor.accent)
        .setupTabBarAppearance()
        .onAppear {
            isWelcomeViewPresented = /*!hasSeenStartScreen*/ true
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
