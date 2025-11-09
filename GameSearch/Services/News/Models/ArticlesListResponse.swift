//
//  ArticlesListResponse.swift
//  GameSearch
//
//  Created by Ацамаз on 01.11.2025.
//

struct ArticlesListResponse: Decodable {
    let data: [ArticlesData]
    let included: [Included]
    
    struct ArticlesData: Decodable {
        let id: String
        let attributes: Attributes
        let relationships: Relationships
        
        struct Attributes: Decodable {
            let title: String
            let slug: String
            let publishedAt: Int
            var image: String?
        }
        
        struct Relationships: Decodable {
            let mainTag: MainTag
            
            struct MainTag: Decodable {
                let data: MainTagData
                
                struct MainTagData: Decodable {
                    let id: String
                }
            }
        }
    }
    
    struct Included: Decodable {
        let id: String
        let attributes: Attributes
        
        struct Attributes: Decodable {
            let name: ArticalType?
        }
    }
}

enum ArticalType: Decodable {
    case dota2
    case cs2
    case other

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        switch rawValue {
        case "Dota 2":
            self = .dota2
        case "CS2":
            self = .cs2
        default:
            self = .other
        }
    }
}
