//
//  SpotifyOptionDisplay.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/30/24.
//

import SwiftUI

struct SpotifyOptionDisplay: View {
    @ObservedObject var spotifyController: SpotifyController
    @Binding var dataString: String
    @State private var searchResult: SearchResult?
    var body: some View {
        VStack{
            if let albums = searchResult?.albums.items {
                ScrollView {
                    ForEach(albums, id: \.id) { album in
                        AlbumRow(album: album, spotifyController: spotifyController)
                            .padding(.vertical, 8)
                    }
                }
            }
        }.onChange(of: dataString, { oldData, newData in
            let jsonData = Data(newData.utf8)
            do {
                let decoder = JSONDecoder()
                searchResult = try decoder.decode(SearchResult.self, from: jsonData)
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
                        ForEach(0..<3, id: \.self) { index in
                            VStack{
                                Spacer()
                                RoundedRectangle(cornerRadius: 3)
                                    .frame(width: min(geometry.size.height / 2,geometry.size.width/4), height: heights[index])
                                    .foregroundColor(grayBlue)
                                    .animation(.spring,value:true)
                            }.offset(y:5)
                        }
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


struct AlbumRow: View {
    var album: Album
    @ObservedObject var spotifyController: SpotifyController

    var body: some View {
        HStack {
            if let firstImageURL = album.images.first?.url {
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
                }
            }

            VStack(alignment: .leading) {
                Text(album.name)
                    .font(.headline)
                Text(album.artists.first?.name ?? "")
                    .font(.subheadline)
                Text(album.release_date)
                    .font(.subheadline)
                Link("Open in Spotify", destination: URL(string: album.externalURL)!)
            }
            .padding(.horizontal)
            .frame(width: screenWidth / 2 - 10, alignment: .leading)

            VStack{
                if spotifyController.currentAlbum == album.uri{
                    Spacer()
                }
                Button(action: {
                    spotifyController.playSpotifyAlbum(uri: album.uri)
                }) {
                    Image("playButton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(width: 50, height: 50)
                if spotifyController.currentAlbum == album.uri{
                    SoundWaveView().frame(width: 50, height: 30).padding(.bottom)
                }
            }.frame(width: 50, height: 100)
        }.padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10.0))
    }
}


// Define Codable structs for parsing JSON
struct SearchResult: Codable {
    let albums: AlbumResponse
}

struct AlbumResponse: Codable {
    let items: [Album]
}

struct Album: Codable, Identifiable {
    let id: String
    let name: String
    let artists: [Artist]
    let release_date: String
    let uri: String
    let images: [SpotifyImage]
    // Add other properties as needed

    var externalURL: String {
        return "https://open.spotify.com/album/\(id)"
    }
}

struct Artist: Codable {
    let name: String
    // Add other properties as needed
}

struct SpotifyImage: Codable{
    let height: Int
    let width: Int
    let url: URL
}

#Preview {
    SoundWaveView().frame(width:150, height:150)
}

let test = """
  {
    "albums" : {
      "href" : "https://api.spotify.com/v1/search?query=album%3ATalking+Heads+%2777+artist%3ATalking+Heads&type=album&locale=en-US%2Cen%3Bq%3D0.9&offset=0&limit=3",
      "items" : [ {
        "album_type" : "album",
        "artists" : [ {
          "external_urls" : {
            "spotify" : "https://open.spotify.com/artist/2x9SpqnPi8rlE9pjHBwmSC"
          },
          "href" : "https://api.spotify.com/v1/artists/2x9SpqnPi8rlE9pjHBwmSC",
          "id" : "2x9SpqnPi8rlE9pjHBwmSC",
          "name" : "Talking Heads",
          "type" : "artist",
          "uri" : "spotify:artist:2x9SpqnPi8rlE9pjHBwmSC"
        } ],
        "available_markets" : [ "AR", "AU", "AT", "BE", "BO", "BR", "BG", "CA", "CL", "CO", "CR", "CY", "CZ", "DK", "DO", "DE", "EC", "EE", "SV", "FI", "FR", "GR", "GT", "HN", "HK", "HU", "IS", "IE", "IT", "LV", "LT", "LU", "MY", "MT", "MX", "NL", "NZ", "NI", "NO", "PA", "PY", "PE", "PH", "PL", "PT", "SG", "SK", "ES", "SE", "CH", "TW", "TR", "UY", "US", "GB", "AD", "LI", "MC", "ID", "JP", "TH", "VN", "RO", "IL", "ZA", "SA", "AE", "BH", "QA", "OM", "KW", "EG", "MA", "DZ", "TN", "LB", "JO", "PS", "IN", "KZ", "MD", "UA", "AL", "BA", "HR", "ME", "MK", "RS", "SI", "KR", "BD", "PK", "LK", "GH", "KE", "NG", "TZ", "UG", "AG", "AM", "BS", "BB", "BZ", "BT", "BW", "BF", "CV", "CW", "DM", "FJ", "GM", "GE", "GD", "GW", "GY", "HT", "JM", "KI", "LS", "LR", "MW", "MV", "ML", "MH", "FM", "NA", "NR", "NE", "PW", "PG", "WS", "SM", "ST", "SN", "SC", "SL", "SB", "KN", "LC", "VC", "SR", "TL", "TO", "TT", "TV", "VU", "AZ", "BN", "BI", "KH", "CM", "TD", "KM", "GQ", "SZ", "GA", "GN", "KG", "LA", "MO", "MR", "MN", "NP", "RW", "TG", "UZ", "ZW", "BJ", "MG", "MU", "MZ", "AO", "CI", "DJ", "ZM", "CD", "CG", "IQ", "LY", "TJ", "VE", "ET", "XK" ],
        "external_urls" : {
          "spotify" : "https://open.spotify.com/album/0r7o2FeARRr23EZ0TJ0a8S"
        },
        "href" : "https://api.spotify.com/v1/albums/0r7o2FeARRr23EZ0TJ0a8S",
        "id" : "0r7o2FeARRr23EZ0TJ0a8S",
        "images" : [ {
          "height" : 640,
          "url" : "https://i.scdn.co/image/ab67616d0000b273b74dc29f68a36438421a9f1d",
          "width" : 640
        }, {
          "height" : 300,
          "url" : "https://i.scdn.co/image/ab67616d00001e02b74dc29f68a36438421a9f1d",
          "width" : 300
        }, {
          "height" : 64,
          "url" : "https://i.scdn.co/image/ab67616d00004851b74dc29f68a36438421a9f1d",
          "width" : 64
        } ],
        "name" : "Talking Heads '77",
        "release_date" : "1977-09-16",
        "release_date_precision" : "day",
        "total_tracks" : 11,
        "type" : "album",
        "uri" : "spotify:album:0r7o2FeARRr23EZ0TJ0a8S"
      }, {
        "album_type" : "album",
        "artists" : [ {
          "external_urls" : {
            "spotify" : "https://open.spotify.com/artist/2x9SpqnPi8rlE9pjHBwmSC"
          },
          "href" : "https://api.spotify.com/v1/artists/2x9SpqnPi8rlE9pjHBwmSC",
          "id" : "2x9SpqnPi8rlE9pjHBwmSC",
          "name" : "Talking Heads",
          "type" : "artist",
          "uri" : "spotify:artist:2x9SpqnPi8rlE9pjHBwmSC"
        } ],
        "available_markets" : [ "AR", "AU", "AT", "BE", "BO", "BR", "BG", "CA", "CL", "CO", "CR", "CY", "CZ", "DK", "DO", "DE", "EC", "EE", "SV", "FI", "FR", "GR", "GT", "HN", "HK", "HU", "IS", "IE", "IT", "LV", "LT", "LU", "MY", "MT", "MX", "NL", "NZ", "NI", "NO", "PA", "PY", "PE", "PH", "PL", "PT", "SG", "SK", "ES", "SE", "CH", "TW", "TR", "UY", "US", "GB", "AD", "MC", "ID", "JP", "TH", "VN", "RO", "IL", "ZA", "SA", "AE", "BH", "QA", "OM", "KW", "EG", "MA", "DZ", "TN", "LB", "JO", "IN", "BY", "KZ", "MD", "UA", "AL", "BA", "HR", "ME", "MK", "RS", "SI", "KR", "BD", "PK", "LK", "GH", "KE", "NG", "TZ", "UG", "AG", "AM", "BS", "BB", "BZ", "BW", "BF", "CV", "CW", "DM", "FJ", "GM", "GD", "GW", "HT", "JM", "LS", "LR", "MW", "ML", "FM", "NA", "NE", "PG", "SM", "ST", "SN", "SC", "SL", "KN", "LC", "VC", "TL", "TT", "AZ", "BN", "BI", "KH", "CM", "TD", "KM", "GQ", "SZ", "GA", "GN", "KG", "LA", "MO", "MR", "MN", "NP", "RW", "TG", "UZ", "ZW", "BJ", "MG", "MU", "MZ", "AO", "CI", "DJ", "ZM", "CD", "CG", "IQ", "LY", "TJ", "VE", "ET", "XK" ],
        "external_urls" : {
          "spotify" : "https://open.spotify.com/album/5eqcF7pWzHgWpGdEmHgeSN"
        },
        "href" : "https://api.spotify.com/v1/albums/5eqcF7pWzHgWpGdEmHgeSN",
        "id" : "5eqcF7pWzHgWpGdEmHgeSN",
        "images" : [ {
          "height" : 640,
          "url" : "https://i.scdn.co/image/ab67616d0000b273e71708b667804f6241dd1a59",
          "width" : 640
        }, {
          "height" : 300,
          "url" : "https://i.scdn.co/image/ab67616d00001e02e71708b667804f6241dd1a59",
          "width" : 300
        }, {
          "height" : 64,
          "url" : "https://i.scdn.co/image/ab67616d00004851e71708b667804f6241dd1a59",
          "width" : 64
        } ],
        "name" : "Talking Heads '77 (Deluxe Version)",
        "release_date" : "1977-09-16",
        "release_date_precision" : "day",
        "total_tracks" : 16,
        "type" : "album",
        "uri" : "spotify:album:5eqcF7pWzHgWpGdEmHgeSN"
      } ],
      "limit" : 3,
      "next" : null,
      "offset" : 0,
      "previous" : null,
      "total" : 2
    }
  }
"""
