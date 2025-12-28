//
//  ArticlesListResponse.swift
//  GameSearch
//
//  Created by Ацамаз on 01.11.2025.
//

struct ArticlesListResponse: Decodable {
    let data: [ArticlesData]
    let included: [ArticlesIncluded]
    
    struct ArticlesData: Decodable {
        let id: String
        let attributes: Attributes
        let relationships: ArticlesRelationships
        
        struct Attributes: Decodable {
            let title: String
            let slug: String
            let publishedAt: Int
            var image: String?
        }
    }
}
