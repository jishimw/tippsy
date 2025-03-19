//
//  SearchService.swift
//  Tippsy
//
//  Created by Nathan Bissett on 2025-03-18.
//

import Foundation

struct SearchService {
    static let shared = SearchService()
    
    static let baseURL = "http://localhost:3000"
    
    
    static func fetchTopUsers(query: String, completion: @escaping ([User]) -> Void) {
        guard var urlComponents = URLComponents(string: "\(baseURL)/search/users") else {
            completion([])
            return
        }
       
        if !query.isEmpty {
            urlComponents.queryItems = [URLQueryItem(name: "username", value: query)]
        }
       
        guard let url = urlComponents.url else {
            completion([])
            return
        }
       
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Error fetching users: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async { completion([]) }
                return
            }
            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                DispatchQueue.main.async { completion(users) }
            } catch {
                print("Error decoding users: \(error)")
                DispatchQueue.main.async { completion([]) }
            }
        }.resume()
    }

    
    static func fetchTopDrinks(completion: @escaping ([Drink]) -> Void) {
        guard let url = URL(string: "\(baseURL)/reviews/mostReviewedDrinks") else { return }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("❌ Error fetching users: \(error?.localizedDescription ?? "Unknown error")")
                    DispatchQueue.main.async { completion([]) }
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                            print("📡 Status Code: \(httpResponse.statusCode)")
                        }

                        print("📜 Raw User Data: \(String(data: data, encoding: .utf8) ?? "nil")")
                
                
                do {
                    let drinks = try JSONDecoder().decode([Drink].self, from: data)
                    DispatchQueue.main.async { completion(Array(drinks.prefix(5))) }
                } catch {
                    print("Error decoding drinks: \(error)")
                    DispatchQueue.main.async { completion([]) }
                }
            }.resume()
        }
    
}


