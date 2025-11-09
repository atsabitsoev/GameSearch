//
//  ScreenFactoryProtocol.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//

import SwiftUI

protocol ScreenFactoryProtocol {
    associatedtype ClubList: View
    associatedtype ClubDetails: View
    
    associatedtype ArticlesList: View
    associatedtype ArticleDetails: View

    
    func makeClubListView() -> ClubList
    func makeClubDetailsView(_ data: ClubDetailsData) -> ClubDetails
    
    func makeArticlesListView() -> ArticlesList
    func makeArticleDetailsView(article: Article) -> ArticleDetails
}
