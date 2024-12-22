//
//  MainTabView.swift
//  Tippsy
//
//  Created by Nathan Bissett on 2024-12-04.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
            
            ProfileView() // Placeholder for a potential Profile page
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
            
            LoginView() // Login tab
                .tabItem {
                    Label("Login", systemImage: "key")
                }
                        
            RegistrationView() // Registration tab
                .tabItem {
                    Label("Register", systemImage: "person.badge.plus")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
