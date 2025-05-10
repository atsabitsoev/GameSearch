//
//  ClubListProtocols.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import Foundation


protocol ClubListViewModelProtocol: ObservableObject {
    var clubs: [Club] { get }
    
    func searchTextChanged(_ searchText: String)
}
