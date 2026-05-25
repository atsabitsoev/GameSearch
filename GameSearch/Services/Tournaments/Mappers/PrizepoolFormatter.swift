//
//  PrizepoolFormatter.swift
//  GameSearch
//
//  Parses PandaScore prizepool strings like "1250000 United States Dollar"
//  into structured `Prizepool` values and formats them for UI.
//

import Foundation

enum PrizepoolFormatter {

    static func parse(_ raw: String?) -> Prizepool? {
        guard let raw, !raw.isEmpty else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        guard let amountSubstring = parts.first else { return nil }
        let normalizedAmount = amountSubstring.replacingOccurrences(of: ",", with: "")
        guard let amount = Decimal(string: normalizedAmount) else { return nil }
        let currency: String
        if parts.count > 1 {
            currency = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            currency = ""
        }
        return Prizepool(amount: amount, currency: currency)
    }

    static func formatted(_ prizepool: Prizepool) -> String {
        let amount = prizepool.amount
        if amount >= 1_000_000 {
            let millions = NSDecimalNumber(decimal: amount)
                .dividing(by: NSDecimalNumber(value: 1_000_000))
            let value = millions.doubleValue
            return String(format: "$%.2fM", value)
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        let number = NSDecimalNumber(decimal: amount)
        let formattedAmount = formatter.string(from: number) ?? number.stringValue
        return "$\(formattedAmount)"
    }
}
