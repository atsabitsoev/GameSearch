//
//  BindingExtesions.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 15.05.2025.
//

import SwiftUI

extension Binding<Bool> {
    init(bindingOptional: Binding<(some Any)?>) {
        self.init(
            get: { bindingOptional.wrappedValue != nil },
            set: { newValue in
                guard newValue == false else { return }
                bindingOptional.wrappedValue = nil
            }
        )
    }
    
    init(bindingOptionalInversed: Binding<(some Any)?>) {
        self.init(
            get: { bindingOptionalInversed.wrappedValue == nil },
            set: { newValue in
                guard newValue != false else { return }
                bindingOptionalInversed.wrappedValue = nil
            }
        )
    }
}

extension Binding {
    public func mappedToBool<Wrapped>(inverse: Bool = false) -> Binding<Bool> where Value == Wrapped? {
        if inverse {
            return Binding<Bool>(bindingOptionalInversed: self)
        } else {
            return Binding<Bool>(bindingOptional: self)
        }
    }
}
