import SwiftSoup
import Foundation


/// Парсер клубов с подробным логированием и извлечением JSON
final class ClubParserService {
    private static let coreUrl = "https://langame.ru"
    
    static func parse(clubLinks: [URL], completion: @escaping ([FullClubData]) -> Void) {
        completion(clubLinks.compactMap{ parse(clubLink: $0) })
    }
    
    static func parse(clubLink: URL) -> FullClubData? {
        do {
            let myHTMLString = try String(contentsOf: clubLink, encoding: .utf8)
            let document = try SwiftSoup.parse(myHTMLString)
            let name = try document.select("h1.title.title-large.text-medium.mb-0").text()
            let images = try document.select("div.club__images-wrapper.d-none.d-lg-block").select("img").map{ try $0.attr("data-src")}
            let addressString = try document.select("div.club__location.d-flex.align-items-center").select("span").first?.text() ?? "Адрес не указан"
            let coordinates = try document.select("div.card.bg-white").attr("data-coords").split(separator: ", ").compactMap{ Double($0) }
            let description = try document.select("div.club__description.my-5.pt-4").select("p").text()
            let rating = Double(try document.select("p.rating__value.text-regular.ps-3.mb-0").text()) ?? 0
            let tags = try document.select("ul.club__services-list.w-100.mb-2").select("li.d-flex.align-items-center").map{ try $0.text() }
            let phone = try document.select("a.d-flex.align-items-center").select("b").text()
            let priceImage = URL(string: coreUrl + (try document.select("section.club__price.mb-5").select("a").map({ try $0.attr("data-src") }).first ?? ""))
            let tableHead = try document.select("thead.club__configuration-table-thead").select("th")
            let roomNames = try tableHead.compactMap{ try $0.select("p").first()?.text() }
            let pcCounts = try tableHead.compactMap{ try Int($0.select("p").last()?.text().split(separator: " ").first ?? "") }
            let minPrice = Int(try document.select("section.club__price.mb-5").select("p").first()?.text().split(separator: " ").filter({ $0.allSatisfy({ $0.isNumber }) }).first ?? "") ?? 0
            let configurationsData = try document.select("table.table.club__configuration-table").select("tbody").first?.children().map{ try $0.children().map{ try $0.text() } } ?? []
            let configurations = getConfigurationsFromData(configurationsData, names: roomNames, pcCounts: pcCounts, minPrice: minPrice)
            return FullClubData(
                additionalInfo: "",
                addressData: AddressData(address: addressString, longitude: coordinates.last ?? 0, latitude: coordinates.first ?? 0),
                comments: [],
                configurations: configurations,
                description: description,
                id: UUID().uuidString,
                images: images,
                name: name,
                nameLowercase: name.lowercased(),
                rating: rating,
                subscribers: 0,
                tags: tags,
                logo: "",
                phoneNumber: phone,
                allPricesImage: priceImage
            )
        } catch let error {
            print("Error: \(error)")
            return nil
        }
    }
    
    
    private static func getConfigurationsFromData(_ data: [[String]], names: [String], pcCounts: [Int], minPrice: Int) -> [RoomConfiguration] {
        var chips: [String] = []
        var videocards: [String] = []
        var rams: [String] = []
        var keyboards: [String] = []
        var mouses: [String] = []
        var headphoness: [String] = []
        var monitors: [String] = []

        var current: String = ""
        for arr in data {
            var i = 0
            for element in arr {
                if i == 0 {
                    current = element
                } else {
                    switch current {
                    case "Процессор":
                        chips.append(element)
                    case "Видеокарта":
                        videocards.append(element)
                    case "Оперативная память":
                        rams.append(element)
                    case "Клавиатура":
                        keyboards.append(element)
                    case "Мышь":
                        mouses.append(element)
                    case "Гарнитура":
                        headphoness.append(element)
                    case "Монитор":
                        monitors.append(element)
                    default:
                        break
                    }
                }
                i += 1
            }
        }
        
        return names.enumerated().map { index, name in
            RoomConfiguration.pc(
                PCConfiguration(
                    chip: chips[index],
                    games: [],
                    headphones: headphoness[index],
                    hz: 0,
                    keyboard: keyboards[index],
                    maxPriceForHour: 0,
                    minPriceForHour: minPrice,
                    monitor: monitors[index],
                    monitorDiag: 0,
                    mouse: mouses[index],
                    ram: rams[index],
                    roomName: name,
                    stationCount: pcCounts[index],
                    type: "pc",
                    videoCard: videocards[index]
                )
            )
        }
    }
}
