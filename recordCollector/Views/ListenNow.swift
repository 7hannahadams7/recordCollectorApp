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
    
    @State private var searchResult: SearchResult?
    
    @State private var displayResults: Bool = false
    
    @State private var dataString = test
    
    var body: some View {
//        let record = viewModel.recordLibrary.last
        ZStack{
            Color(woodAccent).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            VStack{
                RecordImageDisplayView(viewModel: viewModel, record: record, newPhoto: .constant(true), editingMode: .constant(false))
                if displayResults{
                    SpotifyOptionDisplay(spotifyController:spotifyController,dataString:$dataString).frame(height:screenHeight/2)
                }
            }
        }.onAppear(){
            searchSpotifyAlbum(albumName: record.name, artistName: record.artist) { result in
                switch result {
                case .success(let data):
                    // Handle the data (parse JSON, etc.)
                    dataString = String(data: data, encoding: .utf8)!
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
    
    func searchSpotifyAlbum(albumName: String, artistName: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let baseEndpoint = "https://api.spotify.com/v1/search"
        
        // Construct the query string
        let albumString = "album:" + albumName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let artistString = "artist:" + artistName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let queryString = "q=" + albumString + "%20" + artistString + "&type=album&limit=3"
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


