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
                MainTabView() // Access the main app after login
            } else {
                LoginOrRegisterView(isLoggedIn: $isLoggedIn) // Pass binding to update login state
            }
        }
    }
}
