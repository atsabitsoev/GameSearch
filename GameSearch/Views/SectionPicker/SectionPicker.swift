//
//  SectionPicker.swift
//  GameSearch
//
//  Created by Ацамаз on 21.05.2025.
//

import SwiftUI


// enum для пикера
enum DetailsSection {
    case common
    case specification


    var title: String {
        switch self {
        case .common:
            return "Общая информация"
        case .specification:
            return "Характеристики"
        }
    }
}


struct SectionPicker: View {
    @Binding var selectedSection: DetailsSection
    let sections: [DetailsSection]
    
    var body: some View {
        Picker("", selection: $selectedSection) {
            ForEach(sections, id: \.self) { section in
                Text(section.title).tag(section)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}


#Preview {
    SectionPicker(selectedSection: .constant(.common), sections: [.common, .specification])
}
