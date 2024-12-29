
//
//  EditProfileView.swift
//  Tippsy
//
//  Created by Joelle Ishimwe on 2024-12-25.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Binding var user: User?

    @State private var username: String = ""
    @State private var profilePicture: UIImage? // Store UIImage instead of URL
    @State private var preferences: Preferences = Preferences(drink: [], restaurant: [])

    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showPhotoPicker = false // To trigger image picker
    @State private var showAddDrink = false // To add drink preference
    @State private var showAddRestaurant = false // To add restaurant preference
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    // Profile Picture Selector
                    if let profilePicture = profilePicture {
                        Image(uiImage: profilePicture)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    } else {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                    Button("Change Profile Picture") {
                        showPhotoPicker = true
                    }
                    .sheet(isPresented: $showPhotoPicker) {
                        PHPickerViewControllerWrapper(selectedImage: $profilePicture)
                    }

            VStack(alignment: .leading) {
                Text("Drink Preferences")
                    .font(.headline)

                List {
                    ForEach(preferences.drink, id: \.self) { drink in
                        Text(drink)
                            .swipeActions {
                                Button(role: .destructive) {
                                    preferences.drink.removeAll { $0 == drink }
                                } label: {
                                    Text("Delete")
                                }
                            }
                    }
                }
                Button("Add Drink") {
                    showAddDrink = true
                }
                .padding(.top)
            }
            .sheet(isPresented: $showAddDrink) {
                AddPreferenceView(preferenceType: "Drink", preferences: $preferences.drink)
            }

            VStack(alignment: .leading) {
                Text("Restaurant Preferences")
                    .font(.headline)

                List {
                    //make it so the user can scroll through the list of restaurants in the restaurant preference section
                    ForEach(preferences.restaurant, id: \.self) { restaurant in
                        Text(restaurant)
                            .swipeActions {
                                Button(role: .destructive) {
                                    preferences.restaurant.removeAll { $0 == restaurant }
                                } label: {
                                    Text("Delete")
                                }
                            }
                    }
                }
                Button("Add Restaurant") {
                    showAddRestaurant = true
                }
                .padding(.top) 
                .padding(.bottom)
            }
            .sheet(isPresented: $showAddRestaurant) {
                AddPreferenceView(preferenceType: "Restaurant", preferences: $preferences.restaurant)
            }

            Button(action: updateProfile) {
                Text("Save Changes")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .padding()

            Button("Cancel") {
                dismiss()
            }
            .padding()

            Spacer()
        }
        .padding()
        .onAppear {
            if let user = user {
                username = user.username
                preferences = user.preferences
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            ImagePicker(selectedImage: $profilePicture)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Profile Update"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func updateProfile() {
        guard let userId = AuthService.loggedInUserId else { return }
        
        let profilePictureBase64 = profilePicture.flatMap { convertImageToBase64(image: $0) } ?? ""
        
        let updatedUser = User(
            id: userId,
            username: username,
            email: user?.email ?? "",
            profilePicture: profilePictureBase64, // Pass the base64 string
            preferences: preferences,
            friends: user?.friends ?? []
        )
        
        AuthService.updateUserProfile(user: updatedUser) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    user = updatedUser
                    alertMessage = "Profile updated successfully!"
                    showAlert = true
                    dismiss()
                case .failure(let error):
                    alertMessage = "Error updating profile: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images // Limit to images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.selectedImage = image as? UIImage
                }
            }
        }
    }
}

// PHPicker Wrapper
struct PHPickerViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PHPickerViewControllerWrapper
        
        init(_ parent: PHPickerViewControllerWrapper) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                self.parent.selectedImage = image as? UIImage
            }
        }
    }
}

func convertImageToBase64(image: UIImage) -> String? {
    guard let resizedImage = image.resized(toWidth: 200), // Resize to width 200
          let imageData = resizedImage.jpegData(compressionQuality: 0.5) else { return nil }
    return imageData.base64EncodedString()
}

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
