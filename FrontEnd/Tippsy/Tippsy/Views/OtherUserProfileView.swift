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

    var body: some View {
        ScrollView { // Wrap the entire content in a ScrollView
            VStack {
                if let user = viewModel.user {
                    // Display user profile information
                    AsyncImage(url: URL(string: user.profilePicture ?? "")) { image in
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

                    // Display followers
                    HStack {
                        ForEach(user.followers.prefix(3), id: \.self) { follower in
                            AsyncImage(url: URL(string: follower.profilePicture ?? "")) { image in
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

                    // Display reviews
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

                    // Display preferences
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

                    // Follow/Unfollow button
                    if viewModel.isFollowing {
                        Button("Unfollow") {
                            print("Trying to unfollow user: \(viewModel.user?.id ?? "Unknown")")
                            viewModel.unfollowUser { success in
                                if success {
                                    print("Successfully unfollowed user")
                                    viewModel.isFollowing = false // Update the follow state
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
                            viewModel.followUser { success in
                                if success {
                                    print("Successfully followed user")
                                    viewModel.isFollowing = true // Update the follow state
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
            .padding(.bottom, 20) // Add some padding at the bottom to ensure the button doesn't overlap with the bottom bar
        }
        .onAppear {
            // Fetch the user's profile data when the view appears
            if let userId = viewModel.user?.id {
                AuthService.fetchUserProfile(userId: userId) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let profile):
                            viewModel.user = profile.user
                            reviews = profile.reviews
                        case .failure(let error):
                            print("Error fetching profile: \(error.localizedDescription)")
                        }
                    }
                }
            }
            // Check follow state when the view appears
            viewModel.checkIfFollowing()
        }
    }
}