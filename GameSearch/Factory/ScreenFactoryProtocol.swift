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
    func makeClubListView() -> List
    func makeClubDetailsView(_ data: ClubDetailsData) -> Details
}
