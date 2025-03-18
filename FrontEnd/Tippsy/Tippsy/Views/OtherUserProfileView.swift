//
//  OtherUserProfileView.swift
//  Tippsy
//
//  Created by Kyloc Kwan on 2025-03-18.
//

import SwiftUI

struct OtherUserProfileView: View {
    @ObservedObject var viewModel: UserViewModel
    @State private var reviews: [Review] = []
    @State private var isFollowing: Bool = false

    var body: some View {
        VStack {
            if let user = viewModel.user {
                AsyncImage(url: URL(string: user.profilePicture)) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 10)

                Text(user.username)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 10)

                Text("Followers: \(user.followers.count)")
                    .padding(.top, 10)

                HStack {
                    ForEach(user.followers.prefix(3), id: \.self) { follower in
                        AsyncImage(url: URL(string: follower.profilePicture)) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 10)
                    }
                }

                Text("Reviews: \(reviews.count)").padding(.top, 10)
                if reviews.isEmpty {
                    Text("No reviews yet")
                        .italic()
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                } else {
                    List(reviews.prefix(3), id: \.id) { review in
                        VStack(alignment: .leading) {
                            Text("Drink: \(review.drinkName ?? "N/A")")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            Text("Restaurant: \(review.restaurantName ?? "N/A")")
                                .font(.subheadline)
                            Text("Rating: \(review.rating)/5")
                                .font(.subheadline)
                            Text(review.comment)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 5)
                    }
                    .frame(height: 200)
                }

                ZStack {
                    Color.gray.opacity(0.2).cornerRadius(10)
                    VStack(alignment: .leading) {
                        Text("Drink Preferences").font(.headline)
                        ForEach(user.preferences.drink, id: \.self) { drink in
                            Text(drink)
                        }
                        Text("Restaurant Preferences").font(.headline)
                        ForEach(user.preferences.restaurant, id: \.self) { restaurant in
                            Text(restaurant)
                        }
                    }
                    .padding()
                }
                .padding()

                if isFollowing {
                    Button("Unfollow") {
                        AuthService.unfollowUser(userId: user.id) { result in
                            switch result {
                            case .success:
                                isFollowing = false
                                viewModel.fetchUserProfile() // Refresh the profile
                            case .failure(let error):
                                print("Failed to unfollow: \(error.localizedDescription)")
                            }
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
                } else {
                    Button("Follow") {
                        AuthService.followUser(userId: user.id) { result in
                            switch result {
                            case .success:
                                isFollowing = true
                                viewModel.fetchUserProfile() // Refresh the profile
                            case .failure(let error):
                                print("Failed to follow: \(error.localizedDescription)")
                            }
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            viewModel.fetchUserProfile()
            reviews = viewModel.reviews
            AuthService.checkIfFollowing(userId: viewModel.user?.id ?? "") { result in
                switch result {
                case .success(let following):
                    isFollowing = following
                case .failure(let error):
                    print("Failed to check follow status: \(error.localizedDescription)")
                }
            }
        }
    }
}
