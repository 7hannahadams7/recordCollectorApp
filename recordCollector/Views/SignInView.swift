//
//  SignInView.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/14/24.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var authManager: AuthenticationManager

    var body: some View {
        ZStack{
            //Background Image
            Image("Main-Page-Background-1").resizable().edgesIgnoringSafeArea(.all)

            VStack {
                Text("Welcome!").largeHeadlineText().padding(5)
                Text("Please sign in to Firebase to continue").subtitleText()
                VStack{
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Sign In") {
                        signIn()
                    }
                }.padding().background(decorWhite).clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)).padding()
            }
            .padding().background(lightWoodBrown).clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)).padding()
        }
    }

    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                // Handle the error (e.g., show an alert)
            } else {
                print("User signed in successfully")
                authManager.isUserSignedIn = true // Update the authentication state
                // Dismiss the authentication view or navigate to the main part of the app
            }
        }
    }
}


#Preview {
    SignInView(authManager:AuthenticationManager())
}
