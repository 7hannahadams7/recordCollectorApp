//
//  Settings.swift
//  test3
//
//  Created by Hannah Adams on 1/10/24.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @ObservedObject var authManager: AuthenticationManager

    var body: some View {
            
            //Background Decor
            ZStack{
                
                //Background Image
                Color(woodBrown).edgesIgnoringSafeArea(.all)
                // Sign Out Button
                Button("Sign Out") {
                    signOut()
                }

            }.ignoresSafeArea()

    }
    
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            authManager.isUserSignedIn = false
            print("User signed out successfully")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
            
}

#Preview {
    SettingsView(authManager:AuthenticationManager())
}
