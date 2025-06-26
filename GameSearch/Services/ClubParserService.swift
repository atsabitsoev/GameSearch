import SwiftSoup
import Foundation


struct ClubListResponse: Codable {
    let html: String
    let last: Int
    let current: Int
    let total: Int
    let hasMoreClubs: Bool
    let totalForView: Int
}

class ClubParser {
    func fetchClubs(page: Int, completion: @escaping ([FullClubData], Bool) -> Void) {
        // URL с параметрами запроса
        let urlString = "https://langame.ru/computerniy_club_rossiya?page=\(page)&search=&order=rating&order_key=desc&show=list"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("ru", forHTTPHeaderField: "Accept-Language")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        // Создаем и запускаем задачу
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response: \(response.debugDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let jsonResponse: ClubListResponse = try JSONDecoder().decode(ClubListResponse.self, from: data)
                let links = self.parseLinks(from: jsonResponse.html).map{ "https://langame.ru" + $0 }
                ClubParserService.parse(clubLinks: links.compactMap{ URL(string: $0) }) { clubs in
                    completion(clubs, jsonResponse.hasMoreClubs)
                }
            } catch {
                print("JSON decoding error: \(error)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
            }
        }
        
        task.resume()
    }
    
    private func parseLinks(from html: String) -> [String] {
        var links = [String]()
        
        do {
            let document = try SwiftSoup.parse(html)
            let clubCards = try document.select(".js-card-club")
            
            for card in clubCards {
                if let linkElement = try card.select(".card__title a").first() {
                    let href = try linkElement.attr("href")
                    if try card.select("div.card__reservation.text-center.card__reservation-closed-forever").isEmpty() {
                        if !href.isEmpty {
                            links.append(href)
                        }
                    } else {
                        print("ЗАКРЫТО!!!!!! \(href)")
                    }
                }
            }
        } catch {
            print("HTML parsing error: \(error)")
        }
        
        return links
    }
}


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
                    if imageLink.hasPrefix("https://langame.ru") {
                        return imageLink
                    } else {
                        return "https://langame.ru" + imageLink
                    }
                }
                let addressString = try document.select("div.club__location.d-flex.align-items-center").select("span").first?.text() ?? "Адрес не указан"
                let coordinates = try document.select("div.card.bg-white").attr("data-coords").split(separator: ", ").compactMap{ Double($0) }
                let description = try document.select("div.club__description.my-5.pt-4").select("p").text()
                let rating = Double(try document.select("p.rating__value.text-regular.ps-3.mb-0").text()) ?? 0
                let tags = try document.select("ul.club__services-list.w-100.mb-2").select("li.d-flex.align-items-center").map{ try $0.text() }
                let phone = try document.select("a.d-flex.align-items-center").select("b").text()
                let priceImage = URL(string: coreUrl + (try document.select("section.club__price.mb-5").select("a").map({ try $0.attr("data-src") }).first ?? ""))
                let tableHead = try document.select("thead.club__configuration-table-thead").select("th")
                let roomNames = try tableHead.compactMap{ try $0.select("p").first()?.text() }
                let pcCounts = try tableHead.map{ try Int($0.select("p").last()?.text().split(separator: " ").first ?? "") ?? 0 }
                let minPrice = Int(try document.select("section.club__price.mb-5").select("p").first()?.text().split(separator: " ").filter({ $0.allSatisfy({ $0.isNumber }) }).first ?? "") ?? 0
                let configurationsData = try document.select("table.table.club__configuration-table").select("tbody").first?.children().map{ try $0.children().map{ try $0.text() } } ?? []
                let configurations = getConfigurationsFromData(configurationsData, names: roomNames, pcCounts: pcCounts, minPrice: minPrice)
                let data = FullClubData(
                    additionalInfo: "",
                    addressData: AddressData(address: addressString, longitude: coordinates.last ?? 0, latitude: coordinates.first ?? 0),
                    comments: [],
                    configurations: configurations,
                    description: description,
                    id: UUID().uuidString,
                    images: correctedImages,
                    name: name,
                    nameLowercase: name.lowercased(),
                    rating: rating,
                    subscribers: 0,
                    tags: tags,
                    logo: "",
                    phoneNumber: phone,
                    allPricesImage: priceImage
                )
                DispatchQueue.main.async {
                    completion(data)
                }
            } catch let error {
                print("Error: \(error)")
                completion(nil)
            }
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
