//
//  Models.swift
//  Tippsy
//
//  Created by Joelle Ishimwe on 2024-12-25.
//

struct User: Codable, Hashable {
    let id: String
    var username: String
    let email: String
    var profilePicture: String
    var preferences: Preferences
    var friends: [User]

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
}

struct Preferences: Codable {
    var drink: [String]
    var restaurant: [String]
}

struct ProfileResponse: Codable {
    let user: User
    let reviews: [Review]
}
