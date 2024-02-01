//
//  SpotifyOptionDisplay.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/30/24.
//

import SwiftUI

struct SpotifyOptionDisplay: View {
    @ObservedObject var spotifyController: SpotifyController
    @Binding var albumDataString: String
    @Binding var remasterDataString: String
    @Binding var playlistDataString: String
    @State private var albumSearchResult: AlbumSearchResult?
    @State private var remasterSearchResult: AlbumSearchResult?
    @State private var playlistSearchResult: PlaylistSearchResult?
    var body: some View {
        VStack{
            List {
                Section(header: Text("Album")){
                    ScrollView {
                        if let albums = albumSearchResult?.albums.items {
                            ForEach(albums, id: \.id) { album in
                                SpotifyDisplayRow(album: album, spotifyController: spotifyController)
                                    .padding(.vertical, 8)
                            }
                        }
                        if let remasters = remasterSearchResult?.albums.items {
                            
                            ForEach(remasters, id: \.id) { album in
                                SpotifyDisplayRow(album: album, spotifyController: spotifyController)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                }
                Section(header: Text("Playlists")){
//                    ScrollView {
                        if let playlists = playlistSearchResult?.playlists.items {
                            ForEach(playlists, id: \.id) { playlist in
                                SpotifyDisplayRow(playlist: playlist, spotifyController: spotifyController)
                            }
                        }
//                    }
                }
            }.listStyle(.inset).cornerRadius(10).padding(.all, 20)
        }.onChange(of: albumDataString, { oldData, newData in
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
    @State private var heights: [CGFloat] = [5,5,5]
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
                VStack{
                    Spacer()
                    HStack(alignment:.bottom,spacing: 2) {
                        Spacer()
                        ForEach(0..<3, id: \.self) { index in
                            VStack{
                                Spacer()
                                RoundedRectangle(cornerRadius: 3)
                                    .frame(width: min(geometry.size.height / 2,geometry.size.width/4), height: heights[index])
                                    .foregroundColor(grayBlue)
                                    .animation(.spring,value:true)
                            }.offset(y:5)
                        }
                        Spacer()
                    }.frame(height:geometry.size.height).clipped()
                }
                .onAppear {
                    self.animateHeights(within: geometry.size.height)
                }
        }
    }

    func animateHeights(within maxHeight: CGFloat) {
        withAnimation {
            isAnimating.toggle()
            heights = heights.map { _ in CGFloat.random(in: 10...maxHeight) }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            animateHeights(within: maxHeight)
        }
    }
}

struct SpotifyDisplayRow: View {
    var album: Album? = nil
    var playlist: Playlist? = nil
    @ObservedObject var spotifyController: SpotifyController
    
    @State private var imageURL: URL? = nil

    var body: some View {
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
        
        HStack(alignment:.center) {
            
            if album != nil{
                if let firstImageURL = album!.images.first?.url{
                    AsyncImage(url: firstImageURL) { phase in
                        switch phase {
                        case .success(let image):
                            // Image loaded successfully
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75, height: 75)
                        case .failure(_):
                            // Placeholder or error image
                            Image("TakePhoto")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75, height: 75)
                        case .empty:
                            // Placeholder or error image
                            Image("TakePhoto")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75, height: 75)
                        @unknown default:
                            // Placeholder or error image
                            Image("TakePhoto")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75, height: 75)
                        }
                    }.shadow(color:recordBlack, radius: 3.0)
                }
            }
            if playlist != nil{
                if let firstImageURL = playlist!.images.first?.url{
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            // Image loaded successfully
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75, height: 75)
                        case .failure(let error):
                            // Placeholder or error image
                            Image("TakePhoto")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75, height: 75).onAppear{
                                    print(error)
                                }
                        case .empty:
                            // Placeholder or error image
                            Image("TakePhoto")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75, height: 75)
                        @unknown default:
                            // Placeholder or error image
                            Image("TakePhoto")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75, height: 75)
                        }
                    }.shadow(color:recordBlack, radius: 3.0)
                        .onAppear{
                            imageURL = firstImageURL
                        }
                }
            }

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
            VStack(alignment:.center){
                if spotifyController.currentAlbum == uri{
                    Spacer()
                }
                Button(action: {
                    spotifyController.playSpotifyAlbum(uri: uri)
                }) {
                    Image("playButton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(width: 50, height: 50)
                if spotifyController.currentAlbum == uri{
                    SoundWaveView().frame(width: 50, height: 30).padding(.bottom)
                }
            }.frame(width: 50, height: 100)
        }.padding()
    }
}
