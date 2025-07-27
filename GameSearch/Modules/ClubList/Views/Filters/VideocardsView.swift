//
//  VideocardsView.swift
//  GameSearch
//
//  Created by Ацамаз on 27.07.2025.
//

import SwiftUI

struct VideocardsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var parentDisappeared: Bool
    
    @Binding var selectedVideocard: VideocardFilter?
    private let dataArray: [VideocardFilter] = [.series2, .series3, .series4, .series5]
    
    
    init(selectedVideocard: Binding<VideocardFilter?>, parentDisappeared: Binding<Bool>) {
        self._selectedVideocard = selectedVideocard
        self._parentDisappeared = parentDisappeared
    }
    
    
    var body: some View {
        VStack {
            Button {
                selectedVideocard = nil
                dismiss()
            } label: {
                HStack {
                    Text("Не выбрано")
                    Spacer()
                    RadioButton(isSelected: $selectedVideocard.mappedToBool(inverse: true))
                }
            }
            .padding()
            .background(EAColor.info1)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            ForEach(dataArray, id: \.rawValue) { videocard in
                Button {
                    selectedVideocard = videocard
                    dismiss()
                } label: {
                    HStack {
                        Text(videocard.displayText())
                        Spacer()
                        RadioButton(isSelected: isSelectedBinding(id: videocard.rawValue))
                    }
                }
                .padding()
                .background(EAColor.info1)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal)
            Spacer()
        }
        .opacity(parentDisappeared ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: parentDisappeared)
        .foregroundStyle(Color.white)
        .navigationTitle("Видеокарта")
    }
}


private extension VideocardsView {
    func isSelectedBinding(id: Int?) -> Binding<Bool> {
        return Binding<Bool>.init {
            selectedVideocard?.rawValue == id
        } set: { newValue in
            selectedVideocard = dataArray.first(where: { $0.rawValue == id })
        }
    }
}
