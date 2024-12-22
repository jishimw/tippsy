//
//  TippsyApp.swift
//  Tippsy
//
//  Created by Nathan Bissett on 2024-11-18.
//

import SwiftUI

@main
struct TippsyApp: App {
    @State private var isLoggedIn = false // Track login status

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainTabView() // Show main views if logged in
            } else {
                LoginOrRegisterView(isLoggedIn: $isLoggedIn) // Show login/registration otherwise
            }
        }
    }
}
