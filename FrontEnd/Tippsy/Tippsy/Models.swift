//
//  Models.swift
//  Tippsy
//
//  Created by Joelle Ishimwe on 2024-12-25.
//

import Foundation

struct User: Codable, Hashable {
    let id: String
    var username: String
    let email: String
    var profilePicture: String
    var preferences: Preferences
    var followers: [User]
    var following: [User]

    // Conform to Equatable
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }

    // Conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Review: Codable, Identifiable {
    let id: String
    let drinkName: String?
    let restaurantName: String?
    let rating: Int
    let comment: String
    let impairmentLevel: Int
    let photoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case drinkName
        case restaurantName
        case rating
        case comment
        case impairmentLevel = "impairment_level" // Map JSON field to Swift property
        case photoUrl
    }
}

struct Preferences: Codable {
    var drink: [String]
    var restaurant: [String]
}

struct ProfileResponse: Codable {
    let user: User
    let reviews: [Review]
}

struct Location: Codable {
    let type: String
    let coordinates: [Double]
}

struct Restaurant: Codable, Identifiable {
    let id: String?
    let name: String
    let location: Location
    let averageRating: String
    let totalReviews: Int
    let drinks: [String] // Assuming drink names or IDs
    let reviews: [Review]
}

struct Drink: Codable, Identifiable {
    let id: String
    let name: String
    let category: String
    let recipe: Recipe
    let reviews: [String]
}

struct Recipe: Codable {
    let ingredients: [String]
    let instructions: String
}
