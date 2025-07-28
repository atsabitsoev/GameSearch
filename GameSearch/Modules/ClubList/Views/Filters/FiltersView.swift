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
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    @Binding var selectedDetent: PresentationDetent
    
    @State private var viewDisappeared = false
    @State private var videocardFilter: VideocardFilter?
    @State private var presentedSubScreen: SubScreen?
    
    var applyFilters: ([ClubsFilter]) -> ()
    
    
    init(
        isPresented: Binding<Bool>,
        selectedDetent: Binding<PresentationDetent>,
        initialFilters: [ClubsFilter],
        applyFilters: @escaping ([ClubsFilter]) -> Void
    ) {
        self._isPresented = isPresented
        self._selectedDetent = selectedDetent
        self.applyFilters = applyFilters
        initialFilters.forEach { filter in
            switch filter {
            case .videocard(let videocardFilter):
                self._videocardFilter = State(initialValue: videocardFilter)
            default: break
            }
        }
    }
    
    
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
                    applyFilters(getCurrentFilters())
                    dismiss()
                } label: {
                    Text("Применить")
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity)
                .background(Color.accent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.top, 32)
                Button {
                    cleanFilters()
                    applyFilters([])
                    dismiss()
                } label: {
                    Text("Сбросить")
                        .foregroundStyle(Color.red)
                }
                .padding(.top, 8)
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
                selectedDetent = .height(236)
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
    
    func getCurrentFilters() -> [ClubsFilter] {
        var result = [ClubsFilter]()
        if let videocardFilter {
            result.append(.videocard(videocardFilter))
        }
        return result
    }
    
    func cleanFilters() {
        videocardFilter = nil
    }
}
