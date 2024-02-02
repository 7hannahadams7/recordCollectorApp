//
//  test3App.swift
//  test3
//
//  Created by Hannah Adams on 1/8/24.
//

import SwiftUI
import FirebaseCore

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
struct test3App: App {
    // register app delegate for Firebase setup
    
//    init() {
//        FirebaseApp.configure()
//    }
//
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let urlImageService = URLImageService(fileStore: URLImageFileStore(),
                                              inMemoryStore: URLImageInMemoryStore())
    
    @ObservedObject var spotifyController = SpotifyController()
    @ObservedObject var libraryViewModel = LibraryViewModel()

    var body: some Scene {
        WindowGroup {
//            ListenNow(viewModel:libraryViewModel,spotifyController:spotifyController)
            ContentView(viewModel:libraryViewModel,spotifyController: spotifyController)
            .onOpenURL { url in
                spotifyController.setAccessToken(from: url)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didFinishLaunchingNotification), perform: { _ in
                spotifyController.connect()
            })
            .environment(\.urlImageService, urlImageService)
        }
    }
}
