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

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel:libraryViewModel,spotifyController: spotifyController)
            .onOpenURL { url in
                spotifyController.setAccessToken(from: url)
            }
            .environment(\.colorScheme, .light)
            .environment(\.urlImageService, urlImageService)
        }
    }
}
