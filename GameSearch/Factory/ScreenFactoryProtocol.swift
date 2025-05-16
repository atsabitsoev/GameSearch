//
//  ScreenFactoryProtocol.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//

import SwiftUICore

protocol ScreenFactoryProtocol {
    associatedtype Screen: View
    func makeClubListView() -> Screen
}
