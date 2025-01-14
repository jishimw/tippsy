import SwiftUI

@available(iOS 18.0, *) // Ensures compatibility with iOS 18
struct Post: Identifiable {
    let id = UUID()
    let username: String
    let drinkName: String
    let review: String
    let rating: Int
    let profileImage: String
}

@available(iOS 18.0, *) // Ensures compatibility with iOS 18
struct HomeView: View {
    // Sample posts data
    let posts: [Post] = [
        Post(username: "John Doe", drinkName: "Mojito", review: "Refreshing and minty!", rating: 5, profileImage: "person"),
        Post(username: "Jane Smith", drinkName: "Espresso Martini", review: "Perfect balance of coffee and vodka.", rating: 4, profileImage: "person.fill"),
        Post(username: "Chris Evans", drinkName: "Old Fashioned", review: "Classic and strong!", rating: 5, profileImage: "person.circle")
    ]

    var body: some View {
        NavigationStack {
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
                        Text("Your Drink Feed")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.leading)
                            .padding(.top)

                        ForEach(posts) { post in
                            PostCard(post: post)
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

@available(iOS 18.0, *) // Ensures compatibility with iOS 18
struct PostCard: View {
    let post: Post
    @State private var isLiked: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // User Info Row
            HStack {
                Image(systemName: post.profileImage)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 4)

                VStack(alignment: .leading) {
                    Text(post.username)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("⭐ \(post.rating)/5")
                        .font(.subheadline)
                        .foregroundColor(ratingColor(for: post.rating))
                }

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut) {
                        isLiked.toggle()
                    }
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .gray)
                        .scaleEffect(isLiked ? 1.2 : 1.0)
                        .animation(.spring(), value: isLiked)
                }
            }

            // Drink Name
            Text(post.drinkName)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.orange)

            // Review
            Text(post.review)
                .font(.body)
                .foregroundColor(.secondary)

        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.orange.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 4)
        .padding(.horizontal)
    }

    // Helper function to determine the rating color
    private func ratingColor(for rating: Int) -> Color {
        switch rating {
        case 5:
            return .green
        case 3...4:
            return .yellow
        default:
            return .red
        }
    }
}

@available(iOS 18.0, *)
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
