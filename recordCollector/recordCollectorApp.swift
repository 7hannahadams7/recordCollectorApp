//
//  test3App.swift
//  test3
//
//  Created by Hannah Adams on 1/8/24.
//

import SwiftUI
import FirebaseCore

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
    
    var libraryViewModel = LibraryViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel:libraryViewModel)
        }
    }
}
