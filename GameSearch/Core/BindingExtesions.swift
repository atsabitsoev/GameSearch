//
//  BindingExtesions.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 15.05.2025.
//

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
}

extension Binding {
  public func mappedToBool<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
    Binding<Bool>(bindingOptional: self)
  }
}
