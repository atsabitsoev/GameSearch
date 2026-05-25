//
//  CountryFlag.swift
//  GameSearch
//
//  Renders a country flag emoji derived from an ISO 3166-1 alpha-2 code.
//  When the code is missing or invalid, returns a globe symbol instead.
//

import SwiftUI

struct CountryFlag: View {
    let code: String?

    var body: some View {
        Group {
            if let flag = CountryFlag.emoji(from: code) {
                Text(flag)
            } else {
                Image(systemName: "globe")
                    .foregroundStyle(EAColor.textSecondary)
            }
        }
        .font(EAFont.description)
        .accessibilityLabel(Text(code?.uppercased() ?? "Без страны"))
    }

    static func emoji(from code: String?) -> String? {
        guard let code, code.count == 2 else { return nil }
        let upper = code.uppercased()
        var scalarString = ""
        for char in upper.unicodeScalars {
            guard ("A"..."Z").contains(char),
                  let scalar = Unicode.Scalar(0x1F1E6 + (char.value - 0x41))
            else { return nil }
            scalarString.unicodeScalars.append(scalar)
        }
        return scalarString
    }
}

#Preview {
    HStack(spacing: 12) {
        CountryFlag(code: "DK")
        CountryFlag(code: "RU")
        CountryFlag(code: "UA")
        CountryFlag(code: nil)
        CountryFlag(code: "XYZ")
    }
    .padding()
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
