//
//  ListenNow.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/29/24.
//

import SwiftUI

struct ListenNow: View {
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    @State var record: RecordItem
    
    @State private var searchResult: AlbumSearchResult?
    
    @State private var displayResults: Bool = false
    
    @State private var albumDataString = test
    @State private var remasterDataString = test
    @State private var playlistDataString = test2
    
    var body: some View {
//        let record = viewModel.recordLibrary.last
        ZStack{
            if displayResults{
                SpotifyOptionDisplay(spotifyController:spotifyController,albumDataString:$albumDataString, remasterDataString: $remasterDataString,playlistDataString:$playlistDataString)
            }
        }.onAppear(){
            searchSpotifyAlbum(albumName: record.name, artistName: record.artist) { result in
                switch result {
                case .success(let data):
                    // Handle the data (parse JSON, etc.)
                    albumDataString = String(data: data, encoding: .utf8)!
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
            searchSpotifyAlbum(albumName: record.name, artistName: record.artist, remaster: true) { result in
                switch result {
                case .success(let data):
                    // Handle the data (parse JSON, etc.)
                    remasterDataString = String(data: data, encoding: .utf8)!
//                    print("HERE", remasterDataString)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
            searchSpotifyPlaylist(albumName: record.name, artistName: record.artist) { result in
                switch result {
                case .success(let data):
                    // Handle the data (parse JSON, etc.)
                    playlistDataString = String(data: data, encoding: .utf8)!
//                    print("HERE", playlistDataString)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
            displayResults.toggle()
        }
//        .onAppear(){
//            viewModel.refreshData()
//        }
//        .onOpenURL { url in
//            spotifyController.setAccessToken(from: url)
//        }
//        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didFinishLaunchingNotification), perform: { _ in
//            spotifyController.connect()
//        })
        
    }
    func searchSpotifyPlaylist(albumName: String, artistName: String, remaster: Bool? = false, completion: @escaping (Result<Data, Error>) -> Void) {
        let baseEndpoint = "https://api.spotify.com/v1/search"
        
        // Construct the query string
        let totalData = albumName + artistName
        let totalString = "playlist:" + totalData.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let queryString = "q=" + totalString + "&type=playlist&limit=5"
//        print("QUERY STRING: ",queryString)
        
        // Replace this with your Spotify API token
        let token = spotifyController.accessToken!
//        print("Access Token: ", token)
        
        guard let url = URL(string: "\(baseEndpoint)?\(queryString)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        // Create a URLRequest with the necessary headers (including authorization)
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Perform the GET request
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                completion(.success(data))
            } else if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func searchSpotifyAlbum(albumName: String, artistName: String, remaster: Bool? = false, completion: @escaping (Result<Data, Error>) -> Void) {
        let baseEndpoint = "https://api.spotify.com/v1/search"
        
        // Construct the query string
        var albumString = "album:" + albumName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if remaster == true{
            let totalName = albumName + "( Remaster )"
            albumString = "album:" + totalName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
        let artistString = "artist:" + artistName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let queryString = "q=" + albumString + "%20" + artistString + "&type=album&limit=5"
//        print("QUERY STRING: ",queryString)
        
        // Replace this with your Spotify API token
        let token = spotifyController.accessToken!
//        print("Access Token: ", token)
        
        guard let url = URL(string: "\(baseEndpoint)?\(queryString)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        // Create a URLRequest with the necessary headers (including authorization)
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Perform the GET request
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                completion(.success(data))
            } else if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }

}


