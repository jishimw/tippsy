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
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(posts) { post in
                        PostCard(post: post)
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
        }
    }
}

@available(iOS 18.0, *) // Ensures compatibility with iOS 18
struct PostCard: View {
    let post: Post
    
    @State private var isLiked: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: post.profileImage)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(.trailing, 10)
                
                Text(post.username)
                    .font(.headline)
                
                Spacer()
            }
            
            Text("**Drink:** \(post.drinkName)")
                .font(.subheadline)
            
            Text(post.review)
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Rating: \(post.rating)/5")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    isLiked.toggle()
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .gray)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.vertical, 5)
    }
}

@available(iOS 18.0, *)
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
