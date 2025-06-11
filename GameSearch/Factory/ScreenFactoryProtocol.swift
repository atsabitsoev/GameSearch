//
//  ScreenFactoryProtocol.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//

import SwiftUI

protocol ScreenFactoryProtocol {
    associatedtype List: View
    associatedtype Details: View
    associatedtype Promos: View
    associatedtype News: View
  
    func makeClubListView() -> List
    func makePromosListView() -> Promos
    func makeNewsView() -> News
    func makeClubDetailsView(_ data: ClubDetailsData) -> Details
}
