//
//  TournamentsStrings.swift
//  GameSearch
//
//  Source of truth for all Russian strings used inside the Tournaments
//  module. Mirrors `docs/tournaments/12-microcopy-ru.md`. When a new string
//  is needed, add it both here and to the doc.
//

import Foundation

enum TournamentsStrings {

    // MARK: - Tab / navigation

    static let tabTitle = "Турниры"
    static let navTitle = "Турниры"

    // MARK: - Games

    static let gameCS2 = "CS2"
    static let gameDota2 = "Dota 2"

    // MARK: - Segments

    static let segmentRunning = "Сейчас"
    static let segmentUpcoming = "Скоро"
    static let segmentPast = "Прошедшие"

    // MARK: - Live strip

    static let liveStripTitle = "Сейчас идёт"

    // MARK: - Empty states

    static let emptyRunningTitle = "Сейчас никто не играет"
    static let emptyRunningSubtitle = "Загляни в раздел «Скоро»"

    static let emptyUpcomingTitle = "Ничего не запланировано"
    static let emptyUpcomingSubtitle = "Загляни позже — расписание обновится"

    static let emptyPastTitle = "Нет прошедших турниров"
    static let emptyPastSubtitle = "Видимо, мы ещё не начали"

    // MARK: - Error states

    static let errorNoInternetTitle = "Нет интернета"
    static let errorNoInternetSubtitle = "Проверь соединение и попробуй ещё раз"

    static let errorTemporaryTitle = "Турниры временно недоступны"
    static let errorTemporarySubtitle = "Это с нашей стороны. Уже чиним."

    static let errorRetryButton = "Повторить"

    // MARK: - Match statuses

    static let matchStatusLive = "LIVE"
    static let matchStatusFinished = "Завершён"
    static let matchStatusCanceled = "Отменён"
    static let matchStatusPostponed = "Перенесён"

    // MARK: - Match format

    static func bestOf(_ n: Int) -> String { "BO\(n)" }

    // MARK: - Tournament details

    static let tournamentDetailsNavTitleFallback = "Турнир"

    static let tournamentTabMatches = "Матчи"
    static let tournamentTabStandings = "Таблица"
    static let tournamentTabBrackets = "Сетка"
    static let tournamentTabParticipants = "Команды"

    static let tournamentPrizeLabel = "Призовой"
    static let tournamentShareButton = "Поделиться"

    static let tournamentBracketsComingSoonTitle = "Сетка скоро появится"
    static let tournamentBracketsComingSoonSubtitle = "Над сеткой плей-офф ещё работаем"

    // MARK: - Standings

    static let standingsColRank = "#"
    static let standingsColTeam = "Команда"
    static let standingsColWins = "В"
    static let standingsColLosses = "П"
    static let standingsColTotal = "Игр"
    static let standingsColMaps = "Карты"
    static let standingsColPoints = "Очки"

    static let standingsEmptyTitle = "Таблицы пока нет"
    static let standingsEmptySubtitle = "Появится после первых матчей"

    // MARK: - Participants

    static let participantsSectionTitle = "Команды-участники"
    static let participantsRosterLabel = "Состав"
    static let participantsNoRoster = "Состав не объявлен"
    static let participantsEmptyTitle = "Команды ещё не объявлены"
    static let participantsEmptySubtitle = "Список появится ближе к старту"

    // MARK: - Matches tab

    static let matchesEmptyTitle = "Расписание ещё не готово"
    static let matchesEmptySubtitle = "Появится ближе к старту"

    // MARK: - Relative time

    static let timeToday = "Сегодня"
    static let timeTomorrow = "Завтра"
    static let timeYesterday = "Вчера"
}
