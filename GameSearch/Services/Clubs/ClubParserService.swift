import SwiftSoup
import Foundation


/// Парсер клубов с подробным логированием и извлечением JSON
final class ClubParserService {
    private static let coreUrl = "https://langame.ru"
    private static let queue = DispatchQueue.global()
    private static let group = DispatchGroup()
    private static var result: [FullClubData] = []
    
    static func parse(clubLinks: [URL], completion: @escaping ([FullClubData]) -> Void) {
        clubLinks.forEach { url in
            group.enter()
            parse(clubLink: url) { data in
                if let data {
                    result.append(data)
                    group.leave()
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            completion(result)
            result = []
        }
    }
    
    static func parse(clubLink: URL, completion: @escaping (FullClubData?) -> Void) {
        queue.async {
            guard let myHTMLString = try? String(contentsOf: clubLink, encoding: .utf8) else {
                completion(nil)
                return
            }
            do {
                let document = try SwiftSoup.parse(myHTMLString)
                let name = try document.select("h1.title.title-large.text-medium.mb-0").text()
                print("Сейчас парсится клуб \(name)")
                print(clubLink.absoluteString)
                let images = try document.select("div.club__images-wrapper.d-none.d-lg-block").select("img").map{ try $0.attr("data-src")}
                let correctedImages = images.map { imageLink in
                    if imageLink.hasPrefix(coreUrl) {
                        return imageLink
                    } else {
                        return "https://langame.ru" + imageLink
                    }
                }
                let id = String(clubLink.absoluteString.split(separator: "/").last?.split(separator: "_").first ?? "")
                let addressString = try document.select("div.club__location.d-flex.align-items-center").select("span").first?.text() ?? "Адрес не указан"
                let coordinates = try document.select("div.card.bg-white").attr("data-coords").split(separator: ", ").compactMap{ Double($0) }
                let description = try document.select("div.club__description.my-5.pt-4").select("p").text()
                let rating = Double(try document.select("p.rating__value.text-regular.ps-3.mb-0").text()) ?? 0
                let tags = try document.select("ul.club__services-list.w-100.mb-2").select("li.d-flex.align-items-center").map{ try $0.text() }
                let phone = try document.select("a.d-flex.align-items-center").select("b").text()
                let priceImageLink = try document.select("section.club__price.mb-5").select("a").map({ try $0.attr("data-src") }).first ?? ""
                let addingCoreUrl = priceImageLink.hasPrefix(coreUrl) ? "" : coreUrl
                let priceImage = URL(string: addingCoreUrl + priceImageLink)
                let tableHead = try document.select("thead.club__configuration-table-thead").select("th")
                let roomNames = try tableHead.compactMap{ try $0.select("p").first()?.text() }
                let pcCounts = try tableHead.dropFirst().map{ try Int($0.select("p").last()?.text().split(separator: " ").first ?? "") ?? 0 }
                let minPrice = Int(try document.select("section.club__price.mb-5").select("p").first()?.text().split(separator: " ").filter({ $0.allSatisfy({ $0.isNumber }) }).first ?? "") ?? 0
                let configurationsData = try document.select("table.table.club__configuration-table").select("tbody").first?.children().map{ try $0.children().map{ try $0.text() } } ?? []
                let configurations = getConfigurationsFromData(configurationsData, names: roomNames, pcCounts: pcCounts, minPrice: minPrice)
                
                parseLogo(name: name, address: addressString) { logoLink in
                    let data = FullClubData(
                        additionalInfo: "",
                        addressData: AddressData(address: addressString, longitude: coordinates.last ?? 0, latitude: coordinates.first ?? 0),
                        comments: [],
                        configurations: configurations,
                        description: description,
                        id: id,
                        images: correctedImages,
                        name: name,
                        nameLowercase: name.lowercased(),
                        rating: rating,
                        subscribers: 0,
                        tags: tags,
                        logo: logoLink,
                        phoneNumber: phone,
                        allPricesImage: priceImage
                    )
                    DispatchQueue.main.async {
                        completion(data)
                    }
                }
            } catch let error {
                print("Error: \(error)")
                completion(nil)
            }
        }
    }
    
    static func parseLogo(name: String, address: String, _ completion: @escaping (String) -> Void) {
        let nameCorrected = name.filter{ $0.isLetter || $0.isNumber || $0.isWhitespace }
        let addressComponents = address.split(separator: ", ")
        let addressCorrected = addressComponents.dropLast(addressComponents.count - 2).joined(separator: ", ")
        let query = "\(nameCorrected) \(addressCorrected)"
        let charSet = CharacterSet.urlQueryAllowed
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: charSet),
              let url = URL(string: "https://yandex.ru/maps/?text=\(encodedQuery)") else {
            completion("")
            return
        }
        guard let myHTMLString = try? String(contentsOf: url, encoding: .utf8) else {
            completion("")
            return
        }
        do {
            let document = try SwiftSoup.parse(myHTMLString)
            let logoLink = try document.select("div.card-header-media-view__logo").select("img").attr("src")
            completion(logoLink)
        } catch {
            print(error.localizedDescription)
            completion("")
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
