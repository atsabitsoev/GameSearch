//
//  ClubParser.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 01.07.2025.
//

import SwiftSoup
import Foundation
import Firebase

/// Парсер клубов с подробным логированием, извлечением JSON и записью данных на бек
final class ClubParser {
    private let baseUrl = "https://langame.ru"
    private let clubsPath = "clubs"
    
    /// Записывает данные клубов в Firestore
    func writeDataToFirestore(page: Int) {
        let db = Firestore.firestore()
        ClubParser().fetchClubs(page: page) { clubs, hasMore in
            clubs.forEach { club in
                let clubDict = club.toDictionary()
                db.collection(self.clubsPath).document(club.id).setData(clubDict) { error in
                    if let error = error {
                        print("Ошибка записи: \(error.localizedDescription)")
                    } else {
                        print("Данные успешно записаны! \(page) страница")
                    }
                }
            }
            if hasMore {
                print("Начинаем грузить \(page) страницу")
                self.writeDataToFirestore(page: page + 1)
            }
        }
    }
    
    private func fetchClubs(page: Int, completion: @escaping ([FullClubData], Bool) -> Void) {
        let urlString = "\(baseUrl)/computerniy_club_rossiya?page=\(page)&search=&order=rating&order_key=desc&show=list"
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
            
            guard let htmlClubsData = data else {
                print("No data received")
                return
            }
            
            do {
                let jsonClubResponse: ClubListResponse = try JSONDecoder().decode(ClubListResponse.self, from: htmlClubsData)
                let clubLinks = self.parseLinks(from: jsonClubResponse.html).compactMap{ URL(string: self.baseUrl + $0) }
                
                ClubParserService.parse(clubLinks: clubLinks) { clubs in
                    completion(clubs, jsonClubResponse.hasMoreClubs)
                }
            } catch {
                print("JSON decoding error: \(error)")
                print("Response data: \(String(data: htmlClubsData, encoding: .utf8) ?? "")")
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
