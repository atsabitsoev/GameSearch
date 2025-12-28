//
//  ArticlesRelationships.swift
//  GameSearch
//
//  Created by Ацамаз on 28.12.2025.
//


struct ArticlesRelationships: Decodable {
    let mainTag: MainTag

    struct MainTag: Decodable {
        let data: MainTagData

        struct MainTagData: Decodable {
            let id: String
        }
    }
}
