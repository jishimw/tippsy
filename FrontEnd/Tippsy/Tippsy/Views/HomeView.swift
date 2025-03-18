import SwiftUI

@available(iOS 18.0, *)
struct HomeView: View {
    @ObservedObject var viewModel: UserViewModel
    @Binding var isLoggedIn: Bool
    @State private var showEditProfile = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange.opacity(0.3), Color.red.opacity(0.5)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        if let user = viewModel.user {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    AsyncImage(url: URL(string: user.profilePicture)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.gray
                                    }
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(radius: 10)

                                    VStack(alignment: .leading) {
                                        Text(user.username)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("Followers: \(user.followers.count)")
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal)

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
                                .padding(.horizontal)

                                Text("Reviews: \(viewModel.reviews.count)")
                                    .padding(.horizontal)
                                    .foregroundColor(.white)

                                if viewModel.reviews.isEmpty {
                                    Text("No reviews yet")
                                        .italic()
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                } else {
                                    ForEach(viewModel.reviews.prefix(5), id: \.id) { review in
                                        VStack(alignment: .leading, spacing: 10) {
                                            if let photoUrl = review.photoUrl, let url = URL(string: photoUrl) {
                                                AsyncImage(url: url) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        ProgressView()
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 150)
                                                            .cornerRadius(10)
                                                    case .failure:
                                                        Image(systemName: "photo")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 150)
                                                            .cornerRadius(10)
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                            }

                                            Text("Drink: \(review.drinkName ?? "N/A")")
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                            Text("Restaurant: \(review.restaurantName ?? "N/A")")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                            Text("Rating: \(review.rating)/5")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                            Text(review.comment)
                                                .font(.body)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        } else {
                            ProgressView("Loading...")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchUserProfile()
            }
        }
    }
}

@available(iOS 18.0, *)
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: UserViewModel(), isLoggedIn: .constant(true))
    }
}
