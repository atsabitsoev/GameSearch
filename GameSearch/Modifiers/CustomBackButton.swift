//
//  CustomBackButton.swift
//  GameSearch
//
//  Created by Ацамаз on 21.05.2025.
//

import SwiftUI

struct BackButtonModifier: ViewModifier {
    @Environment(\.dismiss) var dismiss

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(radius: 0, y: 1)
                    }
                }
            }
    }
}


extension View {
    func customBackButton() -> some View {
        self.modifier(BackButtonModifier())
    }
}
