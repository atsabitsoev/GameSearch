//
//  FiltersView.swift
//  GameSearch
//
//  Created by Ацамаз on 27.07.2025.
//

import SwiftUI


private enum SubScreen {
    case videocardList
}


struct FiltersView: View {
    @Binding var isPresented: Bool
    @Binding var selectedDetent: PresentationDetent
    
    @State private var viewDisappeared = false
    @State private var videocardFilter: VideocardFilter?
    @State private var presentedSubScreen: SubScreen?
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    presentedSubScreen = .videocardList
                    selectedDetent = .height(370)
                } label: {
                    HStack {
                        Text("Видеокарта")
                        Spacer()
                        Text(videocardFilter.displayText())
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.accent)
                    }
                    .padding()
                    .background(videocardFilter == nil ? Color.secondaryBackground : Color.info1)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .foregroundStyle(videocardFilter == nil ? Color.white : Color.info2)
                }
                Button {
                    print("Save")
                } label: {
                    Text("Применить")
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity)
                .background(Color.accent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.top, 32)
                Spacer()
            }
            .padding(.horizontal)
            .background(EAColor.background)
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: videocardListPresented()) {
                VideocardsView(selectedVideocard: $videocardFilter, parentDisappeared: $viewDisappeared)
                    .frame(maxWidth: .infinity)
                    .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
                    .background(EAColor.background)
            }
            .onAppear {
                selectedDetent = .height(200)
                viewDisappeared = false
            }
            .onDisappear {
                viewDisappeared = true
            }
        }
    }
}


private extension FiltersView {
    func videocardListPresented() -> Binding<Bool> {
        return .init {
            presentedSubScreen == .videocardList
        } set: { newValue in
            presentedSubScreen = newValue ? .videocardList : nil
        }

    }
}
