
//
//  CreateReviewView.swift
//  Tippsy
//
//  Created by Joelle Ishimwe on 2024-12-24.

import SwiftUI
import PhotosUI

// MARK: - CreateReviewView

struct CreateReviewView: View {
    
    // MARK: State Properties
    
    // The currently selected restaurant ID (bar)
    @State private var selectedRestaurant: String = ""
    
    // The currently selected drink ID
    @State private var selectedDrink: String = ""
    
    // Rating and impairment level
    @State private var rating: Int = 1
    @State private var impairmentLevel: Int = 1
    
    // User comment for the review
    @State private var comment: String = ""
    
    // Options for restaurants and drinks fetched from the backend
    @State private var restaurantOptions: [(id: String, name: String)] = []
    @State private var drinkOptions: [(id: String, name: String)] = []
    
    // Photo selection state
    @State private var selectedPhoto: UIImage? = nil
    @State private var showPhotoPicker: Bool = false
    
    // Alert presentation state
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    // MARK: Body
    var body: some View {
        ZStack {
            // Background gradient for visual appeal.
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.3), Color.red.opacity(0.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Using ScrollView for vertical scrolling.
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title
                    Text("Create a Review")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    
                    // Photo Picker Section
                    photoPickerSection
                    
                    // Restaurant Picker Section
                    pickerSection(title: "Select Restaurant", selection: $selectedRestaurant, options: restaurantOptions)
                        .onAppear {
                            // Fetch restaurant data every time the view appears.
                            fetchRestaurants()
                        }
                    
                    // Drink Picker Section
                    pickerSection(title: "Select Drink", selection: $selectedDrink, options: drinkOptions)
                        .onAppear {
                            fetchDrinks()
                        }
                    
                    // Rating Stepper Section
                    stepperSection(title: "Rating", value: $rating, range: 1...5)
                    
                    // Impairment Level Stepper Section
                    stepperSection(title: "Impairment Level", value: $impairmentLevel, range: 1...5)
                    
                    // Comment TextField Section
                    commentSection
                    
                    // Submit Button Section
                    submitButton
                }
                .padding()
                // Extra onAppear call to log a message (for commit history details)
                .onAppear {
                    print("CreateReviewView appeared - refreshing data.")
                }
            } // End ScrollView
        } // End ZStack
        .sheet(isPresented: $showPhotoPicker) {
            // Present the PhotoPicker view.
            PhotoPicker(selectedImage: $selectedPhoto)
        }
        .alert(isPresented: $showAlert) {
            // Show an alert when needed.
            Alert(title: Text("Review Submission"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    // MARK: - Subviews
    
    /// Section for the photo picker.
    private var photoPickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Add a Photo")
                .font(.headline)
                .foregroundColor(.white)
            
            if let photo = selectedPhoto {
                // Display the chosen photo.
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else {
                // Button to open photo picker.
                Button(action: {
                    showPhotoPicker = true
                }) {
                    HStack {
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                        Text("Choose Photo")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.7))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
        }
    }
    
    /// Generic Picker Section for both restaurant and drink pickers.
    private func pickerSection(title: String, selection: Binding<String>, options: [(id: String, name: String)]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Picker(title, selection: selection) {
                // For restaurant picker, add a default option.
                if title == "Select Restaurant" {
                    Text("Home").tag("Home")
                }
                ForEach(options, id: \.id) { option in
                    // Display each option's name.
                    Text(option.name).tag(option.id)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
    
    /// Generic stepper section for numerical input.
    private func stepperSection(title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(title): \(value.wrappedValue)")
                .font(.headline)
                .foregroundColor(.white)
            
            Stepper("", value: value, in: range)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .shadow(radius: 5)
        }
    }
    
    /// Comment section with a text field.
    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Write your comment...")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("", text: $comment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .shadow(radius: 5)
        }
    }
    
    /// Submit button section.
    private var submitButton: some View {
        Button(action: {
            // Call submitReview when button pressed.
            submitReview()
        }) {
            Text("Submit Review")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.7))
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding(.vertical)
    }
    
    // MARK: - Networking and Helper Functions
    
    /// Fetches restaurant data from the server.
    private func fetchRestaurants() {
        guard let url = URL(string: "http://localhost:3000/search/allRestaurants") else {
            print("Invalid URL for fetching restaurants")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Log errors if they occur.
            if let error = error {
                print("Error fetching restaurants: \(error.localizedDescription)")
                return
            }
            
            // Parse JSON response.
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                let restaurants = json.compactMap { restaurant -> (id: String, name: String)? in
                    // Extract restaurant id and name.
                    guard let id = restaurant["_id"] as? String,
                          let name = restaurant["name"] as? String else {
                        return nil
                    }
                    return (id: id, name: name)
                }
                
                // Update UI on main thread.
                DispatchQueue.main.async {
                    self.restaurantOptions = restaurants
                    if self.selectedRestaurant.isEmpty, let firstRestaurant = restaurants.first {
                        self.selectedRestaurant = firstRestaurant.id
                        print("Default restaurant set to: \(firstRestaurant.name)")
                    }
                }
            } else {
                print("Failed to parse restaurants JSON response")
            }
        }
        task.resume()
    }
    
    /// Fetches drink data from the server.
    private func fetchDrinks() {
        guard let url = URL(string: "http://localhost:3000/search/allDrinks") else {
            print("Invalid URL for fetching drinks")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching drinks: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    let drinks = json.compactMap { drink -> (id: String, name: String)? in
                        guard let id = drink["_id"] as? String,
                              let name = drink["name"] as? String else {
                            return nil
                        }
                        return (id: id, name: name)
                    }
                    DispatchQueue.main.async {
                        self.drinkOptions = drinks
                        if self.selectedDrink.isEmpty, let firstDrink = drinks.first {
                            self.selectedDrink = firstDrink.id
                            print("Default drink set to: \(firstDrink.name)")
                        }
                    }
                } else {
                    print("Failed to parse drinks JSON response")
                }
            }
        }
        task.resume()
    }
    
    /// Submits the review using a multipart/form-data HTTP POST request.
    private func submitReview() {
        // Ensure the user is logged in.
        guard let userId = AuthService.loggedInUserId else {
            alertMessage = "User not logged in."
            showAlert = true
            return
        }
        
        // Validate review URL.
        guard let url = URL(string: "http://localhost:3000/reviews") else {
            print("Invalid URL for submitting review")
            return
        }
        
        // Create a boundary string.
        let boundary = UUID().uuidString
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Build the HTTP body data.
        var body = Data()
        
        // Dictionary of parameters for the review submission.
        let parameters: [String: Any?] = [
            "user_id": userId,
            "drink_id": selectedDrink,
            "restaurant_id": selectedRestaurant == "Home" ? nil : selectedRestaurant,
            "rating": rating,
            "comment": comment,
            "impairment_level": impairmentLevel
        ]
        
        // Append parameters to the body.
        for (key, value) in parameters {
            if let value = value {
                appendFormField(key: key, value: "\(value)", boundary: boundary, to: &body)
            }
        }
        
        // Append photo data if available.
        if let photo = selectedPhoto, let imageData = photo.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Append closing boundary.
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // Create the data task to send the review.
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "Error: \(error.localizedDescription)"
                    self.showAlert = true
                }
                return
            }
            // On success, update UI and reset the form.
            DispatchQueue.main.async {
                self.alertMessage = "Review submitted successfully!"
                self.showAlert = true
                self.resetForm()
            }
        }.resume()
    }
    
    /// Helper function to append a form field to the HTTP body data.
    private func appendFormField(key: String, value: String, boundary: String, to body: inout Data) {
        if let dashBoundary = "--\(boundary)\r\n".data(using: .utf8) {
            body.append(dashBoundary)
        }
        if let contentDisposition = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8) {
            body.append(contentDisposition)
        }
        if let valueData = "\(value)\r\n".data(using: .utf8) {
            body.append(valueData)
        }
    }
    
    /// Resets all form fields to their initial state.
    private func resetForm() {
        // Reset all state variables.
        selectedRestaurant = ""
        selectedDrink = ""
        rating = 1
        impairmentLevel = 1
        comment = ""
        selectedPhoto = nil
        
        // Log the reset action for debugging purposes.
        print("Form reset to default values.")
    }
}

// MARK: - PhotoPicker

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        // Configure the photo picker to only show images.
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No update needed for now.
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Dismiss the picker.
            picker.dismiss(animated: true)
            
            // Check if a provider is available.
            guard let provider = results.first?.itemProvider else {
                print("No photo provider found.")
                return
            }
            
            // Load the image if possible.
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

// MARK: - Preview

struct CreateReviewView_Preview: PreviewProvider {
    static var previews: some View {
        CreateReviewView()
    }
}
