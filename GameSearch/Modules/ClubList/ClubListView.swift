//
//  ContentView.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import SwiftUI


struct Penis {
    var size: Int
}


struct ClubListView<ViewModel: ClubListViewModelProtocol>: View {
    @State private var searchText = ""
    
    @ObservedObject private(set) var viewModel: ViewModel
    
    
    
    var body: some View {
        tabBar
    }
    
    var navigationView: some View {
        NavigationStack {
            listView
                .searchable(text: $searchText, placement: .automatic ,prompt: "Поиск")
                .navigationTitle("Ближайшие клубы")
        }
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var tabBar: some View {
        TabView {
            Tab("Клубы", systemImage: "house") {
                navigationView
            }
            Tab("Карта", systemImage: "map") {
                Text("Тут был геннадий")
            }
        }
        .tint(Color.purple)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var listView: some View {
        ScrollView {
            ForEach(viewModel.clubs, id: \.name) { club in
                LazyVStack(alignment: .leading) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .circular)
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .bottomTrailing, endPoint: .topLeading))
                            .frame(height: 160)
                        Text("\(club.name)")
                            
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ClubListView(viewModel: ClubListViewModel())
}
