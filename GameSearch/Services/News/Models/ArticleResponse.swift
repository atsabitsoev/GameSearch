//
//  ArticleResponse.swift
//  GameSearch
//
//  Created by Ацамаз on 09.11.2025.
//

struct ArticleResponse: Decodable {
    let data: Data

    struct Data: Decodable {
        let attributes: Attributes

        struct Attributes: Decodable {
            let title: String
            let publishedAt: Int
            let content: Content

            struct Content: Decodable {
                let blocks: [Block]

                struct Block: Decodable {
                    enum CodingKeys: CodingKey {
                        case id
                        case type
                        case data
                    }

                    init(from decoder: any Decoder) throws {
                        let container = try? decoder.container(keyedBy: CodingKeys.self)
                        self.id = (try? container?.decode(String.self, forKey: .id)) ?? ""
                        self.type = (try? container?.decode(BlockType.self, forKey: .type)) ?? .other
                        switch self.type {
                        case .paragraph:
                            if let paragraphBlock = try? container?.decode(ParagraphBlock.self, forKey: .data) {
                                self.data = .paragraph(paragraphBlock)
                            }
                        case .authoredQuote:
                            if let authoredQuoteBlock = try? container?.decode(AuthoredQuoteBlock.self, forKey: .data) {
                                self.data = .authoredQuote(authoredQuoteBlock)
                            }
                        case .other:
                            break
                        }
                    }


                    let id: String
                    let type: BlockType
                    var data: BlockData?

                    enum BlockType: String, Decodable {
                        case paragraph
                        case authoredQuote
                        case other
                    }

                    enum BlockData: Decodable {
                        case paragraph(ParagraphBlock)
                        case authoredQuote(AuthoredQuoteBlock)
                    }

                    struct ParagraphBlock: Decodable {
                        let text: String
                    }

                    struct AuthoredQuoteBlock: Decodable {
                        let name: String
                        let text: String
                        let photo: String
                        let occupation: String
                        let playerSlug: String
                    }
                }
            }
        }
    }
}
