//
//  ClubsFilter.swift
//  GameSearch
//
//  Created by Ацамаз on 13.05.2025.
//

import Foundation


enum ClubsFilter {
    case name(String)
    case videocard(VideocardFilter)
}

enum VideocardFilter: Int {
    case series2 = 2
    case series3 = 3
    case series4 = 4
    case series5 = 5
    
    func displayText() -> String {
        switch self {
        case .series2:
            "от RTX 20 series"
        case .series3:
            "от RTX 30 series"
        case .series4:
            "от RTX 40 series"
        case .series5:
            "от RTX 50 series"
        }
    }
}

extension Optional where Wrapped == VideocardFilter {
    func displayText() -> String {
        switch self {
        case nil:
            "Не выбрано"
        case .some(let value):
            value.displayText()
        }
    }
}
