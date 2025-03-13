//
//  RestaurantView.swift
//  Tippsy
//
//  Created by Kyloc Kwan on 2025-03-12.
//

import SwiftUI

struct RestaurantView: View {
    @ObservedObject var viewModel: RestaurantViewModel
    let restaurantName: String

    var body: some View {
        VStack {
            if let restaurant = viewModel.restaurant {
                Text(restaurant.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Average Rating: \(restaurant.averageRating)/5")
                    .font(.title2)
                    .foregroundColor(.gray)

                Divider()

                if restaurant.reviews.isEmpty {
                    Text("No reviews yet")
                        .italic()
                        .foregroundColor(.gray)
                } else {
                    List(restaurant.reviews, id: \.id) { review in
                        VStack(alignment: .leading) {
                            if let user = viewModel.profileResponse?.user {
                                Text("User: \(user.username)")
                                    .font(.headline)
                            } else {
                                Text("User: Anonymous")
                                    .font(.headline)
                            }

                            Text("Rating: \(review.rating)/5")
                                .font(.subheadline)
                            Text(review.comment)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 5)
                    }
                }
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            viewModel.fetchRestaurantDetails(restaurantName: restaurantName)
            // Fetch user profile if needed
            // viewModel.fetchUserProfile(userId: "someUserId")
        }
    }
}
