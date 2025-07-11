//
//  StringExtensions.swift
//  GameSearch
//
//  Created by Ацамаз on 11.07.2025.
//

extension String {
    func simplifiedAddress() -> String {
        let addressComponents = split(separator: ", ")
        let result = addressComponents.dropLast(addressComponents.count - 2).joined(separator: ", ")
        return result
    }
}
