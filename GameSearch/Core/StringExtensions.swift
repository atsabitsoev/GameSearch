//
//  StringExtensions.swift
//  GameSearch
//
//  Created by Ацамаз on 11.07.2025.
//


import SwiftSoup


extension String {
    func simplifiedAddress() -> String {
        let addressComponents = split(separator: ", ")
        let result = addressComponents.dropLast(addressComponents.count - 2).joined(separator: ", ")
        return result
    }

    func htmlToText() -> String {
        let replacedNewStrings = self.replacingOccurrences(of: "<br>", with: "\\n")
        guard let text = try? SwiftSoup.parse(replacedNewStrings).text().replacingOccurrences(of: "\\n", with: "\n") else { return self }
        return text
    }
}
