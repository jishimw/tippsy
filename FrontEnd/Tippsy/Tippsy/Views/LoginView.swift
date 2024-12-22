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
                        case .success(_):
                            isLoggedIn = true // Update login status
                        case .failure(let error):
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

            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Login"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
