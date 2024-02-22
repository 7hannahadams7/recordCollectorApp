//
//  ContentView.swift
//  test3
//
//  Created by Hannah Adams on 1/8/24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var authManager: AuthenticationManager

    @StateObject private var statsViewModel: StatsViewModel
    @StateObject private var genreManager = GenreManager()

    init(viewModel: LibraryViewModel, spotifyController: SpotifyController, authManager: AuthenticationManager) {
        self.viewModel = viewModel
        self.spotifyController = spotifyController
        self.authManager = authManager
        self._statsViewModel = StateObject(wrappedValue: StatsViewModel(viewModel: viewModel))
    }
    
    var body: some View {
        // Present SignInView if user not signed into a valid Firebase account
//        if !authManager.isUserSignedIn {
//            SignInView(authManager: authManager)
//        } else {
            ZStack {
                TabView {
                    HomePageView(viewModel: viewModel, spotifyController: spotifyController,genreManager:genreManager).tabItem {
                        Image(systemName: "house.fill")
                        Text("Home").bold()
                    }.tag(0)
                    MyLibraryView(viewModel: viewModel, spotifyController: spotifyController,genreManager:genreManager).tabItem {
                        Image(systemName: "filemenu.and.selection")
                        Text("My Library").bold()
                    }.tag(1)
                    MyStatsView(statsViewModel: statsViewModel, spotifyController: spotifyController,genreManager:genreManager).tabItem {
                        Image(systemName: "chart.pie.fill").foregroundColor(.blue)
                        Text("My Stats").bold()
                    }.tag(2)
                    SettingsView(authManager: authManager,spotifyController:spotifyController).tabItem {
                        Image(systemName: "gearshape")
                        Text("Settings").bold()
                    }.tag(3)
                }.accentColor(darkRedBrown)
                    .tint(decorBlack)
                    .onAppear() {
                        let appearance = UITabBarAppearance()
                        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
                        appearance.backgroundColor = UIColor(lightWoodBrown)
                        appearance.shadowColor = UIColor(lightWoodBrown)
                        
                        // Use this appearance when scrolling behind the TabView:
                        UITabBar.appearance().standardAppearance = appearance
                        // Use this appearance when scrolled all the way up:
                        UITabBar.appearance().scrollEdgeAppearance = appearance
                    }
                if viewModel.isRefreshing{
                    RotatingLoadingButton()
                }
            }.onAppear{
                // Pull data once logged in
                viewModel.refreshData()
            }
//        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel:LibraryViewModel(),spotifyController:SpotifyController(),authManager:AuthenticationManager())
    }
}
