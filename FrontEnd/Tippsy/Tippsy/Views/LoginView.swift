//
//  LoginView.swift
//  Tippsy
//
//  Created by Joelle Ishimwe on 2024-12-22.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                AuthService.login(email: email, password: password) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let token):
                            print("Token received: \(token)") // Debug
                            print("isLoggedIn before update: \(isLoggedIn)") // Debug
                            isLoggedIn = true
                            print("isLoggedIn after update: \(isLoggedIn)") // Debug
                            print("isLoggedIn set to true") // Debug
                            dismiss()   // Dismiss the login view
                        case .failure(let error):
                            print("Login error: \(error.localizedDescription)") // Debug
                            alertMessage = error.localizedDescription
                            showAlert = true
                        }
                    }
                }
            }) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Login"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
