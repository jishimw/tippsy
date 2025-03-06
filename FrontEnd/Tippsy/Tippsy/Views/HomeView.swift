import SwiftUI

@available(iOS 18.0, *)
struct Post: Identifiable, Codable {
    let id: UUID
    let username: String
    let drinkName: String
    let review: String
    let rating: Int
    let profileImage: String
}

@available(iOS 18.0, *)
class ReviewService {
    func fetchReviews(completion: @escaping ([Post]) -> Void) {
        guard let url = URL(string: "https://your-backend-url.com/reviews") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching reviews:", error)
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decodedReviews = try JSONDecoder().decode([Post].self, from: data)
                DispatchQueue.main.async {
                    completion(decodedReviews)
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
}

@available(iOS 18.0, *)
struct HomeView: View {
    @State private var posts: [Post] = []

    var body: some View {
        NavigationStack {
            ZStack {
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
            .onAppear {
                ReviewService().fetchReviews { fetchedPosts in
                    self.posts = fetchedPosts
                }
            }
        }
    }
}

@available(iOS 18.0, *)
struct PostCard: View {
    let post: Post
    @State private var isLiked: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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

            Text(post.drinkName)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.orange)

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

    private func ratingColor(for rating: Int) -> Color {
        switch rating {
        case 5: return .green
        case 3...4: return .yellow
        default: return .red
        }
    }
}

@available(iOS 18.0, *)
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
