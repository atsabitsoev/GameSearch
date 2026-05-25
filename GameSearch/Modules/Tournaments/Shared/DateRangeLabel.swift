//
//  DateRangeLabel.swift
//  GameSearch
//
//  Formats a `from`-`to` date range in Russian-friendly short form
//  ("21 мар — 31 мар", "21—31 мар" when same month).
//

import SwiftUI

struct DateRangeLabel: View {
    let from: Date?
    let to: Date?

    var body: some View {
        Text(text)
            .font(EAFont.description)
            .foregroundStyle(EAColor.textSecondary)
            .lineLimit(1)
            .accessibilityLabel(Text(accessibilityText))
    }

    var text: String {
        DateRangeFormatter.shared.string(from: from, to: to)
    }

    private var accessibilityText: String {
        DateRangeFormatter.shared.accessibilityString(from: from, to: to)
    }
}

// MARK: - Formatter

final class DateRangeFormatter {
    static let shared = DateRangeFormatter()

    private let calendar: Calendar
    private let dayMonthFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let monthFormatter: DateFormatter
    private let fullFormatter: DateFormatter

    init() {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "ru_RU")
        self.calendar = cal

        let locale = Locale(identifier: "ru_RU")

        dayMonthFormatter = DateFormatter()
        dayMonthFormatter.locale = locale
        dayMonthFormatter.setLocalizedDateFormatFromTemplate("d MMM")

        dayFormatter = DateFormatter()
        dayFormatter.locale = locale
        dayFormatter.dateFormat = "d"

        monthFormatter = DateFormatter()
        monthFormatter.locale = locale
        monthFormatter.setLocalizedDateFormatFromTemplate("MMM")

        fullFormatter = DateFormatter()
        fullFormatter.locale = locale
        fullFormatter.setLocalizedDateFormatFromTemplate("d MMMM yyyy")
    }

    func string(from: Date?, to: Date?) -> String {
        switch (from, to) {
        case (.some(let f), .some(let t)):
            return rangeString(from: f, to: t)
        case (.some(let f), .none):
            return dayMonthFormatter.string(from: f)
        case (.none, .some(let t)):
            return dayMonthFormatter.string(from: t)
        case (.none, .none):
            return "—"
        }
    }

    func accessibilityString(from: Date?, to: Date?) -> String {
        switch (from, to) {
        case (.some(let f), .some(let t)):
            return "С \(fullFormatter.string(from: f)) по \(fullFormatter.string(from: t))"
        case (.some(let f), .none):
            return fullFormatter.string(from: f)
        case (.none, .some(let t)):
            return fullFormatter.string(from: t)
        case (.none, .none):
            return "Дата не задана"
        }
    }

    private func rangeString(from: Date, to: Date) -> String {
        if calendar.isDate(from, inSameDayAs: to) {
            return dayMonthFormatter.string(from: from)
        }
        let fromComponents = calendar.dateComponents([.year, .month], from: from)
        let toComponents = calendar.dateComponents([.year, .month], from: to)
        if fromComponents.year == toComponents.year && fromComponents.month == toComponents.month {
            let fromDay = dayFormatter.string(from: from)
            let monthDay = dayMonthFormatter.string(from: to)
            return "\(fromDay)–\(monthDay)"
        }
        return "\(dayMonthFormatter.string(from: from)) — \(dayMonthFormatter.string(from: to))"
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        DateRangeLabel(from: Date(), to: Date().addingTimeInterval(86400 * 10))
        DateRangeLabel(from: Date(), to: Date().addingTimeInterval(86400 * 90))
        DateRangeLabel(from: Date(), to: Date())
        DateRangeLabel(from: Date(), to: nil)
        DateRangeLabel(from: nil, to: nil)
    }
    .padding()
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
