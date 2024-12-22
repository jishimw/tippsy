//
//  LoginOrRegisterView.swift
//  Tippsy
//
//  Created by Joelle Ishimwe on 2024-12-22.
//

import SwiftUI

struct LoginOrRegisterView: View {
    @Binding var isLoggedIn: Bool // Bind to login status from TippsyApp

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to Tippsy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()

                Text("Discover, rate, and share your favorite drinks!")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                // Login Button
                NavigationLink(destination: LoginView(isLoggedIn: $isLoggedIn)) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // Register Button
                NavigationLink(destination: RegistrationView(isLoggedIn: $isLoggedIn)) {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
    }
}

struct LoginOrRegisterView_Previews: PreviewProvider {
    @State static var isLoggedIn = false // State variable for testing

    static var previews: some View {
        LoginOrRegisterView(isLoggedIn: $isLoggedIn) // Pass the dynamic binding
    }
}
