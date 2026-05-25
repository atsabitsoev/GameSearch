//
//  MatchTimeFormatter.swift
//  GameSearch
//
//  Formats absolute match times into Russian-friendly relative strings.
//  Used by match rows on tournament details and (Phase 1.C) match
//  details. Source of truth for the date formats listed in
//  `docs/tournaments/12-microcopy-ru.md` (section "Форматирование дат").
//

import Foundation

enum MatchTimeFormatter {

    // MARK: - Singletons

    /// Reused calendar/formatters — cheaper than recreating per row.
    private static let shared = SharedState()

    private final class SharedState {
        let calendar: Calendar
        let timeFormatter: DateFormatter
        let shortDayMonth: DateFormatter
        let shortDayMonthTime: DateFormatter

        init() {
            var cal = Calendar(identifier: .gregorian)
            cal.locale = Locale(identifier: "ru_RU")
            self.calendar = cal

            let locale = Locale(identifier: "ru_RU")

            timeFormatter = DateFormatter()
            timeFormatter.locale = locale
            timeFormatter.dateFormat = "HH:mm"

            shortDayMonth = DateFormatter()
            shortDayMonth.locale = locale
            shortDayMonth.setLocalizedDateFormatFromTemplate("d MMM")

            shortDayMonthTime = DateFormatter()
            shortDayMonthTime.locale = locale
            shortDayMonthTime.setLocalizedDateFormatFromTemplate("d MMM, HH:mm")
        }
    }

    // MARK: - Public

    /// Time for an upcoming/scheduled match.
    /// - "сегодня в 15:00" / "завтра в 15:00" / "5 июн, 15:00".
    static func upcoming(_ date: Date?, relativeTo now: Date = Date()) -> String {
        guard let date else { return "—" }
        let calendar = shared.calendar
        if calendar.isDate(date, inSameDayAs: now) {
            return "\(TournamentsStrings.timeToday.lowercased()) в \(shared.timeFormatter.string(from: date))"
        }
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
           calendar.isDate(date, inSameDayAs: tomorrow) {
            return "\(TournamentsStrings.timeTomorrow.lowercased()) в \(shared.timeFormatter.string(from: date))"
        }
        return shared.shortDayMonthTime.string(from: date)
    }

    /// Time for a finished match.
    /// - "вчера в 15:00" / "сегодня в 15:00" / "5 июн в 15:00".
    static func finished(_ date: Date?, relativeTo now: Date = Date()) -> String {
        guard let date else { return "—" }
        let calendar = shared.calendar
        if calendar.isDate(date, inSameDayAs: now) {
            return "\(TournamentsStrings.timeToday.lowercased()) в \(shared.timeFormatter.string(from: date))"
        }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "\(TournamentsStrings.timeYesterday.lowercased()) в \(shared.timeFormatter.string(from: date))"
        }
        return "\(shared.shortDayMonth.string(from: date)) в \(shared.timeFormatter.string(from: date))"
    }

    /// Short same-day time (used inside ●LIVE rows).
    static func clock(_ date: Date?) -> String {
        guard let date else { return "—" }
        return shared.timeFormatter.string(from: date)
    }
}
