//
//  recordCollectorApp.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/8/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

import URLImage
import URLImageStore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      
      // Check if the user is already signed in
      if Auth.auth().currentUser != nil {
          // User is signed in, proceed to the main part of the app
          // e.g., set up your main view controller
          print("User is signed in")
      } else {
          // User is not signed in, show the authentication view
          // e.g., present the sign-in or sign-up view controller
          print("User is not signed in")
      }

    return true
  }
}


@main
struct recordCollectorApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let urlImageService = URLImageService(fileStore: URLImageFileStore(),
                                              inMemoryStore: URLImageInMemoryStore())
    
    @ObservedObject var spotifyController = SpotifyController()
    @ObservedObject var libraryViewModel = LibraryViewModel()
    
    @State private var isSignInPresented = false
    @State private var isSignUpPresented = false

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel:libraryViewModel,spotifyController: spotifyController)
            .onOpenURL { url in
                print("CALLING OPENURL")
                spotifyController.setAccessToken(from: url)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didFinishLaunchingNotification), perform: { _ in
                print("TRIGGERING CONNECT")
                spotifyController.connect()
            })
            .environment(\.colorScheme, .light)
            .environment(\.urlImageService, urlImageService)
        }
    }
}
