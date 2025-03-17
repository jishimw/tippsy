//
//  UserViewModel.swift
//  Tippsy
//
//  Created by Joelle Ishimwe on 2025-01-05.
//

import Foundation
import Combine

class UserViewModel: ObservableObject {
    @Published var user: User? {
        didSet {
            print("User updated: \(String(describing: user))")
        }
    }
    @Published var reviews: [Review] = []

    func fetchUserProfile() {
        guard let userId = AuthService.loggedInUserId else { return }
        AuthService.fetchUserProfile(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.user = profile.user
                    self.reviews = profile.reviews
                    print("Fetched reviews: \(self.reviews)") // Debug print to check if photoUrl is included
                case .failure(let error):
                    print("Error fetching profile: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateUserProfile(updatedUser: User, completion: @escaping (Bool) -> Void) {
        AuthService.updateUserProfile(user: updatedUser) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.user = updatedUser
                    completion(true)
                case .failure(let error):
                    print("Error updating profile: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
}
