//
//  NewsResponse.swift
//  GameSearch
//
//  Created by Ацамаз on 01.11.2025.
//

struct NewsResponse: Decodable {
    let data: [Data]
    
    struct Data: Decodable {
        let id: String
        let attributes: Attributes
        
        struct Attributes: Decodable {
            let title: String
            let publishedAt: Int
        }
    }
}
