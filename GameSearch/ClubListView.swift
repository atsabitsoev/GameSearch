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


struct ClubListView: View {
    @State private var searchText = ""
    
    let penises = Array(0..<99).map { int in
        return Penis(size: int)
    }
    
    
    var body: some View {
        tabBar
    }
    
    var navigationView: some View {
        NavigationStack {
            listView
                .navigationTitle("Ближайшие клубы")
        }
        .searchable(text: $searchText, prompt: "Поиск")
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        .background(Color.white)
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
            appearance.backgroundColor = UIColor.black
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var listView: some View {
        ScrollView {
            ForEach(penises, id: \.size) { penis in
                LazyVStack(alignment: .leading) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .circular)
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .bottomTrailing, endPoint: .topLeading))
                            .frame(height: 160)
                        Text("\(penis.size)")
                            
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.black)
    }
}

#Preview {
    ClubListView()
}
