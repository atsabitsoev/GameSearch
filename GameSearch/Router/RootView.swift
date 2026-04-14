//
//  RootView.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//

import SwiftUI


struct RootView<Factory: ScreenFactoryProtocol>: View {
    @EnvironmentObject private var clubsRouter: ClubsRouter
    @EnvironmentObject private var articlesRouter: ArticlesRouter

    @State private var currentTab: TabTag = .news
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
        }
        .tint(EAColor.accent)
        .setupTabBarAppearance()
        .onAppear {
            sendTabAnalytics(for: currentTab)
        }
        .onChange(of: currentTab) { _, newTab in
            sendTabAnalytics(for: newTab)
        }
        .onOpenURL { url in
            handleUrl(url)
        }
    }

    func handleUrl(_ url: URL) {
        let deepLink = Deeplink(from: url)
        switch deepLink {
        case .articles(let slug):
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
        }
    }
}
