//
//  StatsViewModel.swift
//  test3
//
//  Created by Hannah Adams on 1/11/24.
//

import Foundation
import SwiftUI
import FirebaseDatabase

class StatsViewModel: ObservableObject {
    @ObservedObject var viewModel: LibraryViewModel
    @Published var topArtists: [(artist: String, count: Int, records: [String])] = []

    func fetchTopArtists() {
        // Firebase query to get top artists and their record counts
        let recordsRef = Database.database().reference().child("Records")

        recordsRef.observeSingleEvent(of: .value) { snapshot in
            var artistData: [(String, Int, [String])] = []

            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let elementDict = snap.value as! [String: Any]

                let recordID = snap.key
                if let artist = elementDict["artist"] as? String {
                    let recordID = snap.key
                    if let index = artistData.firstIndex(where: { $0.0 == artist }) {
                        // Artist already exists in the array, update count and add record ID
                        artistData[index].1 += 1
                        artistData[index].2.append(recordID)
                    } else {
                        // New artist, add to the array
                        artistData.append((artist, 1, [recordID]))
                    }
                }
            }

            // Sort artists by count in descending order
            self.topArtists = artistData.sorted { $0.1 > $1.1 }
        }
    }
    
    var genreTotalData: [DistributionItem] = [
        .init(name: "Classic Rock", amount: 50),
        .init(name: "Punk", amount: 45),
        .init(name: "Alternative", amount: 39),
        .init(name: "Indie", amount: 20),
        .init(name: "Glam Rock", amount: 15),
        .init(name: "Folk", amount: 10),
        .init(name: "Classical", amount: 7),
        .init(name: "Pop", amount: 5),
        .init(name: "Country", amount: 5),
        .init(name: "Blues", amount: 4),
        .init(name: "Sountrack", amount: 3),
        .init(name: "Post-Grunge", amount: 2)
    ]

    var artistTotalData: [DistributionItem] = [
        .init(name: "David Bowie", amount: 14),
        .init(name: "Pink Floyd", amount: 12),
        .init(name: "The Smiths", amount: 10),
        .init(name: "Led Zeppelin", amount: 10),
        .init(name: "Radiohead", amount: 9),
        .init(name: "Simon & Garfunkel", amount: 8),
        .init(name: "Talking Heads", amount: 7),
        .init(name: "Billy Joel", amount: 4),
        .init(name: "Harry Styles", amount: 4),
        .init(name: "Aerosmith", amount: 3),
        .init(name: "Vundabar", amount: 2),
        .init(name: "PUP", amount: 2),
        
    ]
    
    var decadeTotalData: [DistributionItem] = [
        .init(name: "1970s", amount: 24),
        .init(name: "1980s", amount: 22),
        .init(name: "2010s", amount: 20),
        .init(name: "1960s", amount: 15),
        .init(name: "1990s", amount: 9),
        .init(name: "2000s", amount: 8),
        .init(name: "1950s", amount: 7),
        .init(name: "2020s", amount: 4),
        .init(name: "1870s", amount: 2),
    ]
    
    var decadeData: [Int:Int] = [
        1870:2,
        1950:7,
        1960:15,
        1970:24,
        1980:22,
        1990:9,
        2000:8,
        2010:20,
        2020:4
    ]
    
    var yearlyTotalData: [Int:Int] = [
        1970:5,
        1971:4,
        1973:6,
        1975:8,
        1977:3,
        1978:2,
        1980:6,
        1982:1,
        1983:2,
        1984:4,
        1987:7,
        1989:3,
        1990:2,
        1997:5,
        1999:1,
        2000:1,
        2001:1,
        2003:2,
        2005:4,
        2006:2,
        2010:3,
        2014:2,
        2016:6,
        2017:3,
        2023:5
    ]
    
    
    
    
    init(viewModel: LibraryViewModel) {
            self.viewModel = viewModel
            fetchTopArtists()
    }
    
}

struct DistributionItem: Identifiable {
    var name: String
    var amount: Int
    var id = UUID()
}

