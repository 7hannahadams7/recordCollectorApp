//
//  SpotifyCodables.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/1/24.
//

import Foundation

// Define Codable structs for parsing JSON
struct AlbumSearchResult: Codable {
    let albums: AlbumResponse
}
struct PlaylistSearchResult: Codable {
    let playlists: PlaylistResponse
}

struct AlbumResponse: Codable {
    let items: [Album]
}
struct PlaylistResponse: Codable {
    let items: [Playlist]
}

struct Album: Codable, Identifiable {
    let id: String
    let name: String
    let artists: [Artist]
    let release_date: String
    let uri: String
    let images: [SpotifyImage]
    var externalURL: String {
        return "https://open.spotify.com/album/\(id)"
    }
}
struct Playlist: Codable, Identifiable {
    let id: String
    let name: String
    let owner: PlaylistOwner
    let uri: String
    let images: [SpotifyImage]
    var externalURL: String {
        return "https://open.spotify.com/playlist/\(id)"
    }
}

struct Artist: Codable {
    let name: String
}
struct PlaylistOwner: Codable{
    let display_name: String
}

struct SpotifyImage: Codable{
    let height: Int?
    let width: Int?
    let url: URL
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

let test2 = """
{
  "playlists" : {
    "href" : "https://api.spotify.com/v1/search?query=playlist%3ALet%E2%80%99s+DanceDavid+Bowie&type=playlist&locale=en-US%2Cen%3Bq%3D0.9&offset=0&limit=5",
    "items" : [ {
      "collaborative" : false,
      "description" : "The brilliant David Bowie leaves us with a breath-taking body of work across six decades. Bowie influenced everything from classic rock to electronic music, inspiring the punk, synth-pop and post-punk revolutions along the way. He music remains as relevant in the 21st Century as it was in the last.",
      "external_urls" : {
        "spotify" : "https://open.spotify.com/playlist/4qJMdvnnhHAnZ6qRdZADSj"
      },
      "href" : "https://api.spotify.com/v1/playlists/4qJMdvnnhHAnZ6qRdZADSj",
      "id" : "4qJMdvnnhHAnZ6qRdZADSj",
      "images" : [ {
        "height" : null,
        "url" : "https://image-cdn-ak.spotifycdn.com/image/ab67706c0000bebb986fc7013f3459783b1bc211",
        "width" : null
      } ],
      "name" : "David Bowie, Let's Dance 40th Anniversary Celebration",
      "owner" : {
        "display_name" : "PlayStation®️",
        "external_urls" : {
          "spotify" : "https://open.spotify.com/user/playstation_music"
        },
        "href" : "https://api.spotify.com/v1/users/playstation_music",
        "id" : "playstation_music",
        "type" : "user",
        "uri" : "spotify:user:playstation_music"
      },
      "primary_color" : null,
      "public" : null,
      "snapshot_id" : "MjY3LDRmOTY5YjkyZTMwNDdmMTYwMmQzOGJkZmQ3NmFhY2ZlNDY1OTRjN2U=",
      "tracks" : {
        "href" : "https://api.spotify.com/v1/playlists/4qJMdvnnhHAnZ6qRdZADSj/tracks",
        "total" : 107
      },
      "type" : "playlist",
      "uri" : "spotify:playlist:4qJMdvnnhHAnZ6qRdZADSj"
    }, {
      "collaborative" : false,
      "description" : "The very best of David Bowie playlist including top tracks such as Heroes, Starman and Space Oddity. ",
      "external_urls" : {
        "spotify" : "https://open.spotify.com/playlist/52ed11cF35KOKnJsetko4M"
      },
      "href" : "https://api.spotify.com/v1/playlists/52ed11cF35KOKnJsetko4M",
      "id" : "52ed11cF35KOKnJsetko4M",
      "images" : [ {
        "height" : null,
        "url" : "https://image-cdn-ak.spotifycdn.com/image/ab67706c0000bebb0b7e12ca231bb4cf413eb8ef",
        "width" : null
      } ],
      "name" : "David Bowie Official Playlist",
      "owner" : {
        "display_name" : "David Bowie",
        "external_urls" : {
          "spotify" : "https://open.spotify.com/user/david_bowie_"
        },
        "href" : "https://api.spotify.com/v1/users/david_bowie_",
        "id" : "david_bowie_",
        "type" : "user",
        "uri" : "spotify:user:david_bowie_"
      },
      "primary_color" : null,
      "public" : null,
      "snapshot_id" : "MTEyNyxjYWNhMDdjOWNmODU2NzA5NmRmOGE4MmE5MDYxNDcwMWQyZjM0ZDNm",
      "tracks" : {
        "href" : "https://api.spotify.com/v1/playlists/52ed11cF35KOKnJsetko4M/tracks",
        "total" : 79
      },

      "type" : "playlist",
      "uri" : "spotify:playlist:52ed11cF35KOKnJsetko4M"
    }, {
      "collaborative" : false,
      "description" : "Every track in once place. From his debut album in 1967 to his legendary Glastonbury performance in 2000. Listen now to Bowies complete discography. ",
      "external_urls" : {
        "spotify" : "https://open.spotify.com/playlist/0mkz40ZahTeC6y2klc527h"
      },
      "href" : "https://api.spotify.com/v1/playlists/0mkz40ZahTeC6y2klc527h",
      "id" : "0mkz40ZahTeC6y2klc527h",
      "images" : [ {
        "height" : null,
        "url" : "https://image-cdn-ak.spotifycdn.com/image/ab67706c0000bebbf82325ca41f6781c7d911f7b",
        "width" : null
      } ],
      "name" : "David Bowie: Complete Discography",
      "owner" : {
        "display_name" : "David Bowie",
        "external_urls" : {
          "spotify" : "https://open.spotify.com/user/david_bowie_"
        },
        "href" : "https://api.spotify.com/v1/users/david_bowie_",
        "id" : "david_bowie_",
        "type" : "user",
        "uri" : "spotify:user:david_bowie_"
      },
      "primary_color" : null,
      "public" : null,
      "snapshot_id" : "MzMwLGQ5MWM0ZmJmOTg1NDA4MWU5ZmNlNWEzNTgwNjlmMmZlNTFjOTAzYzU=",
      "tracks" : {
        "href" : "https://api.spotify.com/v1/playlists/0mkz40ZahTeC6y2klc527h/tracks",
        "total" : 321
      },
      "type" : "playlist",
      "uri" : "spotify:playlist:0mkz40ZahTeC6y2klc527h"
    }, {
      "collaborative" : false,
      "description" : "This is David Bowie. The essential tracks, all in one playlist.",
      "external_urls" : {
        "spotify" : "https://open.spotify.com/playlist/37i9dQZF1DZ06evO0auErC"
      },
      "href" : "https://api.spotify.com/v1/playlists/37i9dQZF1DZ06evO0auErC",
      "id" : "37i9dQZF1DZ06evO0auErC",
      "images" : [ {
        "height" : null,
        "url" : "https://thisis-images.spotifycdn.com/37i9dQZF1DZ06evO0auErC-large.jpg",
        "width" : null
      } ],
      "name" : "This Is David Bowie",
      "owner" : {
        "display_name" : "Spotify",
        "external_urls" : {
          "spotify" : "https://open.spotify.com/user/spotify"
        },
        "href" : "https://api.spotify.com/v1/users/spotify",
        "id" : "spotify",
        "type" : "user",
        "uri" : "spotify:user:spotify"
      },
      "primary_color" : null,
      "public" : null,
      "snapshot_id" : "Mjg0NDY1MTMsMDAwMDAwMDA3MGYyZTRmMzJmZTZjMzE4YWFkMDA5NDliZTc2ODk5MQ==",
      "tracks" : {
        "href" : "https://api.spotify.com/v1/playlists/37i9dQZF1DZ06evO0auErC/tracks",
        "total" : 55
      },
      "type" : "playlist",
      "uri" : "spotify:playlist:37i9dQZF1DZ06evO0auErC"
    }, {
      "collaborative" : false,
      "description" : "",
      "external_urls" : {
        "spotify" : "https://open.spotify.com/playlist/4yebu47SKvUq8aWmTu1cRc"
      },
      "href" : "https://api.spotify.com/v1/playlists/4yebu47SKvUq8aWmTu1cRc",
      "id" : "4yebu47SKvUq8aWmTu1cRc",
      "images" : [ {
        "height" : null,
        "url" : "https://image-cdn-fa.spotifycdn.com/image/ab67706c0000bebb7bf620327ea6ebb5388e9f25",
        "width" : null
      } ],
      "name" : "David Bowie greatest hits",
      "owner" : {
        "display_name" : "lafyaters",
        "external_urls" : {
          "spotify" : "https://open.spotify.com/user/lafyaters"
        },
        "href" : "https://api.spotify.com/v1/users/lafyaters",
        "id" : "lafyaters",
        "type" : "user",
        "uri" : "spotify:user:lafyaters"
      },
      "primary_color" : null,
      "public" : null,
      "snapshot_id" : "NTYsNzA0OWVkZWQyM2U5OTA0OTIzMWRmNWVhMmU1MWFhMzIxYTM4Mzg1YQ==",
      "tracks" : {
        "href" : "https://api.spotify.com/v1/playlists/4yebu47SKvUq8aWmTu1cRc/tracks",
        "total" : 42
      },
      "type" : "playlist",
      "uri" : "spotify:playlist:4yebu47SKvUq8aWmTu1cRc"
    } ],
    "limit" : 5,
    "next" : "https://api.spotify.com/v1/search?query=playlist%3ALet%E2%80%99s+DanceDavid+Bowie&type=playlist&locale=en-US%2Cen%3Bq%3D0.9&offset=5&limit=5",
    "offset" : 0,
    "previous" : null,
    "total" : 800
  }
}
"""
