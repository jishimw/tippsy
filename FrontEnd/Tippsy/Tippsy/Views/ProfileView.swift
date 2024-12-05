//
//  ProfileView.swift
//  Tippsy
//
//  Created by Nathan Bissett on 2024-12-04.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Image("profile_picture")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 10)

            Text("John Doe")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 10)

            Text("iOS Developer")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 2)
            
            Spacer()
        }
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

