//
//  CreateReviewView.swift
//  Tippsy
//
//  Created by Joelle Ishimwe on 2024-12-24.
//

import SwiftUI
import PhotosUI

struct CreateReviewView: View {
    @State private var selectedRestaurant: String = ""
    @State private var selectedDrink: String = ""
    @State private var rating: Int = 1
    @State private var impairmentLevel: Int = 1
    @State private var comment: String = ""
    @State private var restaurantOptions: [(id: String, name: String)] = []
    @State private var drinkOptions: [(id: String, name: String)] = []
    @State private var selectedPhoto: UIImage? = nil
    @State private var showPhotoPicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Create a Review")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            // Photo Picker
            if let photo = selectedPhoto {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(10)
            } else {
                Button(action: {
                    showPhotoPicker = true
                }) {
                    Text("Add Photo")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }

            // Restaurant Picker
            Picker("Select Restaurant", selection: $selectedRestaurant) {
                Text("Home").tag("Home")
                ForEach(restaurantOptions, id: \.id) { restaurant in
                    Text(restaurant.name).tag(restaurant.id)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onAppear {
                fetchRestaurants()
            }

            // Drink Picker
            Picker("Select Drink", selection: $selectedDrink) {
                ForEach(drinkOptions, id: \.id) { drink in
                    Text(drink.name).tag(drink.id)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onAppear {
                fetchDrinks()
            }

            // Rating Picker
            Stepper("Rating: \(rating)", value: $rating, in: 1...5)

            // Impairment Level Picker
            Stepper("Impairment Level: \(impairmentLevel)", value: $impairmentLevel, in: 1...5)

            // Comment TextField
            TextField("Write your comment...", text: $comment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical)

            // Submit Button
            Button(action: submitReview) {
                Text("Submit Review")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.vertical)

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(selectedImage: $selectedPhoto)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Review Submission"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    // Fetch Restaurants
    func fetchRestaurants() {
        guard let url = URL(string: "http://localhost:3000/search/allRestaurants") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching restaurants: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                let restaurants = json.compactMap { restaurant -> (id: String, name: String)? in
                    guard let id = restaurant["_id"] as? String, let name = restaurant["name"] as? String else { return nil }
                    return (id: id, name: name)
                }
                DispatchQueue.main.async {
                    self.restaurantOptions = restaurants
                    if self.selectedRestaurant.isEmpty, let firstRestaurant = restaurants.first {
                        self.selectedRestaurant = firstRestaurant.id // Default to the first restaurant's ID
                    }
                }
            } else {
                print("Failed to parse restaurants response.")
            }
        }.resume()
    }

    // Fetch Drinks
    func fetchDrinks() {
        guard let url = URL(string: "http://localhost:3000/search/allDrinks") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching drinks: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    let drinks = json.compactMap { drink -> (id: String, name: String)? in
                        guard let id = drink["_id"] as? String, let name = drink["name"] as? String else { return nil }
                        return (id: id, name: name)
                    }
                    DispatchQueue.main.async {
                        self.drinkOptions = drinks
                        if self.selectedDrink.isEmpty, let firstDrink = drinks.first {
                            self.selectedDrink = firstDrink.id // Default to the first drink's ID
                        }
                    }
                } else {
                    print("Failed to parse drinks response.")
                }
            }
        }.resume()
    }
    
    // Submit Review with Photo
    func submitReview() {
        guard let userId = AuthService.loggedInUserId else {
            alertMessage = "User not logged in."
            showAlert = true
            return
        }

        guard let url = URL(string: "http://localhost:3000/reviews") else { return }

        // Create a boundary for the multipart form data
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add user_id, drink_id, restaurant_id, rating, comment, and impairment_level to the body
        let parameters: [String: Any?] = [
            "user_id": userId,
            "drink_id": selectedDrink,
            "restaurant_id": selectedRestaurant == "Home" ? nil : selectedRestaurant,
            "rating": rating,
            "comment": comment,
            "impairment_level": impairmentLevel
        ]

        for (key, value) in parameters {
            if let value = value {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }

        // Add the photo to the body if it exists
        if let photo = selectedPhoto, let imageData = photo.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "Error: \(error.localizedDescription)"
                    self.showAlert = true
                }
                return
            }

            DispatchQueue.main.async {
                self.alertMessage = "Review submitted successfully!"
                self.showAlert = true
                self.resetForm()
            }
        }.resume()
    }

    func resetForm() {
        selectedRestaurant = ""
        selectedDrink = ""
        rating = 1
        impairmentLevel = 1
        comment = ""
        selectedPhoto = nil
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

struct CreateReviewView_Preview: PreviewProvider {
    static var previews: some View {
        CreateReviewView()
    }
}
