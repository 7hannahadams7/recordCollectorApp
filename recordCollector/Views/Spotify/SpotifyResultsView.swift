//
//  SpotifyOptionDisplay.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/30/24.
//

import SwiftUI
import URLImage
import URLImageStore


struct SpotifyResultsView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    @State var record: RecordItem
    @Binding var albumDataString: String
    @Binding var remasterDataString: String
    @Binding var playlistDataString: String
    @State private var albumSearchResult: AlbumSearchResult?
    @State private var remasterSearchResult: AlbumSearchResult?
    @State private var playlistSearchResult: PlaylistSearchResult?
    var body: some View {
        VStack{
            List {
                Section(header: Text("Albums")) {
                    ScrollView {
                        // Combine Album items from both search results without duplicates
                        let allAlbums = ((albumSearchResult?.albums.items ?? []) + (remasterSearchResult?.albums.items ?? [])).removingDuplicates()

                        ForEach(allAlbums) { album in
                            SpotifyDisplayRow(viewModel:viewModel,spotifyController: spotifyController,record:record,album: album)
                                .padding(.vertical, 8)
                        }
                    }
                }
                Section(header: Text("Playlists")){
                    ScrollView{
                        // Pull Playlist items from Search Results
                        if let playlists = playlistSearchResult?.playlists.items {
                            ForEach(playlists.compactMap { $0 }, id: \.id) { playlist in
                                SpotifyDisplayRow(viewModel:viewModel,spotifyController: spotifyController,record:record,playlist: playlist)
                            }
                        }
                    }
                }
            }.listStyle(.inset).cornerRadius(10).padding(.all, 20).preferredColorScheme(.light)
        }// Perfrom data fetches for search results
        .onChange(of: albumDataString, { oldData, newData in
            let jsonData = Data(newData.utf8)
            do {
                let decoder = JSONDecoder()
                albumSearchResult = try decoder.decode(AlbumSearchResult.self, from: jsonData)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        })
        .onChange(of: remasterDataString, { oldData, newData in
            let jsonData = Data(newData.utf8)
            do {
                let decoder = JSONDecoder()
                remasterSearchResult = try decoder.decode(AlbumSearchResult.self, from: jsonData)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        })
        .onChange(of: playlistDataString, { oldData, newData in
            let jsonData = Data(newData.utf8)
            do {
                let decoder = JSONDecoder()
                playlistSearchResult = try decoder.decode(PlaylistSearchResult.self, from: jsonData)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        })
    }
}



struct SoundWaveView: View {
    @State private var heights: [CGFloat] = [5, 5, 5]
    @State private var isAnimating = false
    @Binding var paused: Bool

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Spacer()
                HStack(alignment: .bottom, spacing: 2) { // Adjust alignment here
                    Spacer()
                    ForEach(0..<3, id: \.self) { index in
                        VStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 3)
                                .frame(width: min(geometry.size.height / 2, geometry.size.width / 4), height: heights[index])
                                .foregroundColor(grayBlue)
                                .animation(.spring, value: true)
                        }.offset(y: 3)
                    }
                    Spacer()
                }.frame(width:geometry.size.width, height: geometry.size.height).clipped()
            }
            .onAppear {
                self.animateHeights(within: geometry.size.height)
            }
        }
    }

    func animateHeights(within maxHeight: CGFloat) {
        withAnimation {
            isAnimating.toggle()
            if paused {
                heights = [maxHeight / 2, maxHeight / 2, maxHeight / 2]
            } else {
                heights = heights.map { _ in CGFloat.random(in: 10...maxHeight) }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            animateHeights(within: maxHeight)
        }
    }
}


struct SpotifyDisplayRow: View {
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    var record: RecordItem
    var album: Album? = nil
    var playlist: Playlist? = nil
    
    @State private var imageURL: URL? = nil

    var body: some View {
        // Pull generic items from initializers
        var name: String{
            return album?.name ?? playlist!.name
        }
        var person: String{
            return album?.artists.first?.name ?? playlist!.owner.display_name
        }
        var externalURL: String{
            return album?.externalURL ?? playlist!.externalURL
        }
        var uri: String{
            return album?.uri ?? playlist!.uri
        }
        
        var nowPlaying: Bool{
            return spotifyController.currentPlaying == uri
        }
        
        HStack(alignment:.center) {
            
            // Album Image
            if album != nil{
                if let firstImageURL = album!.images.first?.url{
                    
                    URLImage(firstImageURL) {
                        // This view is displayed before download starts
                        Image("TakePhoto").resizable().aspectRatio(contentMode: .fit)
                    } inProgress: { progress in
                        // Display progress
                        Image("TakePhoto").resizable().aspectRatio(contentMode: .fit)
                    } failure: { error, retry in
                        // Display error and retry button
                        Image("TakePhoto").resizable().aspectRatio(contentMode: .fit)
                    } content: { image in
                        // Downloaded image
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            
                    }.frame(width: 75, height: 75).shadow(color:recordBlack, radius: 3.0)
                    
                }
            }
            
            // OR Playlist Image
            if playlist != nil{
                if let firstImageURL = playlist!.images.first?.url{

                    URLImage(firstImageURL) {
                        // This view is displayed before download starts
                        Image("TakePhoto").resizable().aspectRatio(contentMode: .fit)
                    } inProgress: { progress in
                        // Display progress
                        Image("TakePhoto").resizable().aspectRatio(contentMode: .fit)
                    } failure: { error, retry in
                        // Display error and retry button
                        Image("TakePhoto").resizable().aspectRatio(contentMode: .fit)
                    } content: { image in
                        // Downloaded image
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            
                    }.frame(width: 75, height: 75).shadow(color:recordBlack, radius: 3.0)
                    
                }
            }

            
            // Information Stack
            GeometryReader{geometry in
                VStack(alignment: .leading) {
                    Text(name).minimumScaleFactor(0.85)
                        .font(.headline)
                    Text(person)
                        .font(.subheadline).minimumScaleFactor(0.5).lineLimit(1)
                    if let release_date = album?.release_date{
                        Text(release_date)
                            .font(.subheadline).minimumScaleFactor(0.5).lineLimit(1)
                    }
                    Link("Open in Spotify", destination: URL(string: externalURL)!).minimumScaleFactor(0.5).lineLimit(1)
                }
                .padding(.horizontal)
                .frame(maxWidth:.infinity, alignment: .leading)
            }
            
            // Button Player Stack
            VStack(alignment:.center){
                // Displaying pause and sound bars
                if nowPlaying{
                    Spacer()
                    if spotifyController.playerPaused{
                        Button(action: {
                            spotifyController.resumeSpotifyPlayback()
                        }) {
                            Image("playButton")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .frame(width: 50, height: 50)
                    }else{
                        Button(action: {
                            spotifyController.pauseSpotifyPlayback()
                        }) {
                            Image("pauseButton")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .frame(width: 50, height: 50)
                    }
                    SoundWaveView(paused:$spotifyController.playerPaused).frame(width: 50, height: 30).padding(.bottom)
                }else{
                    Button(action: {
                        spotifyController.playFromSpotify(uri: uri)
                        viewModel.historyViewModel.uploadNewHistoryItem(type: "Listen", recordID: record.id)
                        
                    }) {
                        Image("playButton")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .frame(width: 50, height: 50)
                }
            }.frame(width: 50, height: 100)
        }.padding()
    }
}
