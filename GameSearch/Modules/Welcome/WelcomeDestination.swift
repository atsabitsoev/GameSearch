//
//  WelcomeDestination.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 15.04.2026.
//

import SwiftUI

enum WelcomeDestination: String {
    case clubs
    case news
    case tournaments
}

extension WelcomeDestination {
    var iconName: String {
        switch self {
        case .clubs:
            "gamecontroller.fill"
        case .news:
            "newspaper.fill"
        case .tournaments:
            "trophy.fill"
        }
    }

    var title: String {
        switch self {
        case .clubs:
            "Клубы рядом"
        case .news:
            "Новости игр"
        case .tournaments:
            "Турниры (скоро)"
        }
    }

    var subtitle: String {
        switch self {
        case .clubs:
            "Найди лучшие компьютерные клубы поблизости"
        case .news:
            "Читай самые свежие новости из мира гейминга"
        case .tournaments:
            "Следи за турнирами по CS2, Dota 2 и другим играм"
        }
    }

    var badgeColor: Color {
        switch self {
        case .clubs:
            EAColor.purpleAccent
        case .news:
            EAColor.info2
        case .tournaments:
            EAColor.orange
        }
    }

    var backgroundGradient: LinearGradient {
        switch self {
        case .clubs:
            LinearGradient(colors: [EAColor.purpleAccent.opacity(0.38), EAColor.purpleAccent.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .news:
            LinearGradient(colors: [EAColor.info2.opacity(0.34), EAColor.info2.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .tournaments:
            LinearGradient(colors: [EAColor.orange.opacity(0.42), EAColor.orange.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var borderColor: Color {
        switch self {
        case .clubs:
            EAColor.purpleAccent.opacity(0.52)
        case .news:
            EAColor.info2.opacity(0.52)
        case .tournaments:
            EAColor.orange.opacity(0.62)
        }
    }
}
