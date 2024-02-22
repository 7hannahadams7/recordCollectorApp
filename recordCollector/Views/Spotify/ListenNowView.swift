//
//  ListenNow.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/29/24.
//

import SwiftUI

struct ListenNowView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    @State var record: RecordItem
    
    @State private var searchResult: AlbumSearchResult?
    
    @State private var displayResults: Bool = false
    
    @State private var albumDataString = test
    @State private var remasterDataString = test
    @State private var playlistDataString = test2
    
    var body: some View {

        ZStack{
            // Wait to display results after fetch from Spotify
            if displayResults{
                SpotifyResultsView(spotifyController:spotifyController,albumDataString:$albumDataString, remasterDataString: $remasterDataString,playlistDataString:$playlistDataString)
            }
        }.onChange(of: spotifyController.accessToken, { _, _ in
            // Perform search once connected with valid token
            searchSpotifyData(albumName: record.name, artistName: record.artist)
            displayResults.toggle()
        })
        .onAppear(){
            if spotifyController.connectionFailure{
                // If not connected, trigger connect here
                spotifyController.connect()
                
                // Perform search if access token already exists but controller was disconnected
                if spotifyController.accessToken != nil{
                    searchSpotifyData(albumName: record.name, artistName: record.artist)
                    displayResults.toggle()
                }
            }else{
                searchSpotifyData(albumName: record.name, artistName: record.artist)
                displayResults.toggle()
            }
        }
    }
    
    // Gather all spotify data for given record search
    private func searchSpotifyData(albumName: String, artistName: String, remaster: Bool = false) {
        let group = DispatchGroup()

        var albumData: Data?
        var remasterData: Data?
        var playlistData: Data?

        group.enter()
        searchSpotifyAlbum(albumName: albumName, artistName: artistName) { result in
            defer { group.leave() }
            switch result {
            case .success(let data):
                albumData = data
            case .failure(let error):
                print("Error searching album:", error)
            }
        }

        group.enter()
        searchSpotifyAlbum(albumName: albumName, artistName: artistName, remaster: true) { result in
            defer { group.leave() }
            switch result {
            case .success(let data):
                remasterData = data
            case .failure(let error):
                print("Error searching remaster:", error)
            }
        }

        group.enter()
        searchSpotifyPlaylist(albumName: albumName, artistName: artistName) { result in
            defer { group.leave() }
            switch result {
            case .success(let data):
                playlistData = data
            case .failure(let error):
                print("Error searching playlist:", error)
            }
        }

        group.notify(queue: DispatchQueue.main) {
            if let albumData = albumData {
                self.albumDataString = String(data: albumData, encoding: .utf8)!
            }
            if let remasterData = remasterData {
                self.remasterDataString = String(data: remasterData, encoding: .utf8)!
            }
            if let playlistData = playlistData {
                self.playlistDataString = String(data: playlistData, encoding: .utf8)!
            }
        }
    }
    
    // Pull search data for playlists
    private func searchSpotifyPlaylist(albumName: String, artistName: String, remaster: Bool? = false, completion: @escaping (Result<Data, Error>) -> Void) {
        let baseEndpoint = "https://api.spotify.com/v1/search"
        
        // Construct the query string
        let totalData = albumName + artistName
        let totalString = "playlist:" + totalData.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let queryString = "q=" + totalString + "&type=playlist&limit=5" // Limit to 5 results
        
        // Replace this with your Spotify API token
        let token = spotifyController.accessToken!
        
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
    
    // Pull search data for albums and remastered versions
    private func searchSpotifyAlbum(albumName: String, artistName: String, remaster: Bool? = false, completion: @escaping (Result<Data, Error>) -> Void) {
        let baseEndpoint = "https://api.spotify.com/v1/search"
        
        // Construct the query string
        var albumString = "album:" + albumName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if remaster == true{
            let totalName = albumName + "( Remaster )"
            albumString = "album:" + totalName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
        let artistString = "artist:" + artistName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let queryString = "q=" + albumString + "%20" + artistString + "&type=album&limit=5" // Limit to 5 results
        
        // Replace this with your Spotify API token

        let token = spotifyController.accessToken!
        
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


