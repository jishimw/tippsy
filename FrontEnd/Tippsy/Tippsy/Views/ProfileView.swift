//
//  ProfileView.swift
//  Tippsy
//
//  Created by Nathan Bissett on 2024-12-04.
//

import SwiftUI

struct ProfileView: View {
    @State private var user: User?
    @State private var reviews: [Review] = []
    @State private var showEditProfile = false
    @Binding var isLoggedIn: Bool // Bind to login status from TippsyApp

    var body: some View {
        VStack {
            if let user = user {
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

                //add the user's friend following count
                Text("Friends: \(user.friends.count)")
                    .padding(.top, 10)

                //add the about 3 user friend's profile pictures
                HStack {
                    ForEach(user.friends.prefix(3), id: \.self) { friend in
                        AsyncImage(url: URL(string: friend.profilePicture)) { image in
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

                //add the user's review count
                List(reviews) { review in
                    VStack(alignment: .leading) {
                        Text("Drink: \(review.drinkName ?? "N/A")")
                        Text("Rating: \(review.rating)/5")
                        Text("Comment: \(review.comment)")
                    }
                }.padding(.top, 10)

                //Preferences Area
                ZStack {
                    Color.gray.opacity(0.2) // Light gray background
                        .cornerRadius(10)
                    VStack(alignment: .leading) {
                        Text("Drink Preferences")
                            .font(.headline)
                        ForEach(user.preferences.drink, id: \.self) { drink in
                            Text(drink)
                        }

                        Text("Restaurant Preferences")
                            .font(.headline)
                        ForEach(user.preferences.restaurant, id: \.self) { restaurant in
                            Text(restaurant)
                        }
                    }
                    .padding()
                }
                .padding()


                Button(action: {
                    showEditProfile = true
                }) {
                    Text("Edit Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
                .sheet(isPresented: $showEditProfile, onDismiss: fetchProfile) {
                    EditProfileView(user: $user)
                }
                
                Button(action: logout) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding(.top)

            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear(perform: fetchProfile)
    }

    func fetchProfile() {
        guard let userId = AuthService.loggedInUserId else { return }
        print("The logged in user's Id: \(userId)")
        AuthService.fetchUserProfile(userId: userId) { result in
            switch result {
            case .success(let profile):
                print("Profile: \(profile)")
                self.user = profile.user
                self.reviews = profile.reviews
            case .failure(let error):
                print("Error fetching profile: \(error.localizedDescription)")
            }
        }
    }
    
    func logout() {
        AuthService.loggedInUserId = nil
        AuthService.username = nil
        isLoggedIn = false
    }
}
