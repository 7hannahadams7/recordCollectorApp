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
    return true
  }
}


@main
struct recordCollectorApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let urlImageService = URLImageService(fileStore: URLImageFileStore(),
                                              inMemoryStore: URLImageInMemoryStore())
    
    @StateObject var spotifyController = SpotifyController()
    @StateObject var libraryViewModel = LibraryViewModel()
    @StateObject var authManager = AuthenticationManager()

    var body: some Scene {
        WindowGroup {
            if !authManager.isUserSignedIn {
                SignInView(authManager: authManager)
            } else {
                ContentView(viewModel:libraryViewModel,spotifyController: spotifyController,authManager:authManager)
                    .onOpenURL { url in
                        // Pull token after coming back from Spotify app with URL
                        spotifyController.setAccessToken(from: url)
                    }
                    .environment(\.colorScheme, .light)
                    .environment(\.urlImageService, urlImageService)
            }
        }
    }
}
