//
//  AuthenticationManager.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/18/24.
//

import FirebaseAuth

class AuthenticationManager: ObservableObject {
    @Published var isUserSignedIn = false

    init() {
        // Check the initial authentication state
        isUserSignedIn = Auth.auth().currentUser != nil

        // Add a listener to observe changes in the authentication state
        Auth.auth().addStateDidChangeListener { _, user in
            self.isUserSignedIn = user != nil
        }
    }
}
