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
                        case .header:
                            if let headerBlock = try? container?.decode(HeaderBlock.self, forKey: .data) {
                                self.data = .header(headerBlock)
                            }
                        case .list:
                            if let listBlock = try? container?.decode(ListBlock.self, forKey: .data) {
                                self.data = .list(listBlock)
                            }
                        case .raw:
                            if let webRawBlock = try? container?.decode(WebRawBlock.self, forKey: .data) {
                                self.data = .webRaw(webRawBlock)
                            }
                        case .gallery:
                            if let galleryBlock = try? container?.decode(GalleryBlock.self, forKey: .data) {
                                self.data = .gallery(galleryBlock)
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
                        case header
                        case list
                        case raw
                        case gallery
                        case other
                    }

                    enum BlockData: Decodable {
                        case paragraph(ParagraphBlock)
                        case authoredQuote(AuthoredQuoteBlock)
                        case header(HeaderBlock)
                        case list(ListBlock)
                        case webRaw(WebRawBlock)
                        case gallery(GalleryBlock)
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

                    struct HeaderBlock: Decodable {
                        let text: String
                        let level: Int
                    }

                    struct ListBlock: Decodable {
                        let items: [String]
                    }

                    struct WebRawBlock: Decodable {
                        let html: String
                    }

                    struct GalleryBlock: Decodable {
                        let images: [ImageData]

                        struct ImageData: Decodable {
                            let caption: String
                            let image: String
                        }
                    }
                }
            }
        }
    }
}
