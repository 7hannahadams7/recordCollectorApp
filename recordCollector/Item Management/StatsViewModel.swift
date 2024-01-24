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
    @Published var topArtists: [(artist: String, amount: Int, records: [String])] = []
    @Published var topGenres: [(genre: String, amount: Int, records: [String])] = []
    @Published var topDecades: [(decade: Int, amount: Int, records: [String])] = []
    @Published var topYears: [(year: Int, amount: Int, records: [String])] = []

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
    
    func fetchTopGenres(){
        // Firebase query to get top artists and their record counts
        let recordsRef = Database.database().reference().child("Records")

        recordsRef.observeSingleEvent(of: .value) { snapshot in
            var genreData: [(String, Int, [String])] = []

            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let elementDict = snap.value as! [String: Any]

                let recordID = snap.key

                // Check if "genres" key exists in the dictionary
                if let genresDict = elementDict["genres"] as? [String: Bool] {
                    // Iterate through the keys of the genres dictionary
                    for (genre, value) in genresDict {
                        // Check if the value is true
                        if value {
                            if let index = genreData.firstIndex(where: { $0.0 == genre }) {
                                // Genre already exists in the array, update count and add record ID
                                genreData[index].1 += 1
                                genreData[index].2.append(recordID)
                            } else {
                                // New artist, add to the array
                                genreData.append((genre, 1, [recordID]))
                            }
                        }
                    }
                }
            }

            // Sort artists by count in descending order
            self.topGenres = genreData.sorted { $0.1 > $1.1 }
        }

    }
    
    func fetchTopYears(){
        // Firebase query to get top years and record counts
        let recordsRef = Database.database().reference().child("Records")

        recordsRef.observeSingleEvent(of: .value) { snapshot in
            var decadeData: [(Int, Int, [String])] = []
            var yearlyData: [(Int, Int, [String])] = []

            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let elementDict = snap.value as! [String: Any]

                if let releaseYear = elementDict["releaseYear"] as? Int{
                    let recordID = snap.key
                    if let index = yearlyData.firstIndex(where: { $0.0 == releaseYear}){
//                        Artist already exists in the array, update count and add record ID
                        yearlyData[index].1 += 1
                        yearlyData[index].2.append(recordID)
                    } else {
                        // New artist, add to the array
                        yearlyData.append((releaseYear, 1, [recordID]))
                    }
                    
                    let decade = (releaseYear/10)*10
                    if let index = decadeData.firstIndex(where: { $0.0 == decade}){
//                         Artist already exists in the array, update count and add record ID
                        decadeData[index].1 += 1
                        decadeData[index].2.append(recordID)
                        //                        artistData[index].2.append(recordID)
                    } else {
                        // New artist, add to the array
                        decadeData.append((decade, 1, [recordID]))
                    }
                    
                }

            }
            
            decadeData.append((2000, 6,["16FBA54D-1A8E-423D-8252-BA3CF06AF727"]))
            decadeData.append((2010, 4,["16FBA54D-1A8E-423D-8252-BA3CF06AF727"]))
            decadeData.append((1990, 1,["16FBA54D-1A8E-423D-8252-BA3CF06AF727"]))
            decadeData.append((1950, 2,["16FBA54D-1A8E-423D-8252-BA3CF06AF727"]))
            
            yearlyData.append((2001, 1,[]))
            yearlyData.append((2004, 1,[]))
            yearlyData.append((2007, 1,[]))
            yearlyData.append((2003, 1,[]))
            yearlyData.append((2005, 1,[]))
            yearlyData.append((2004, 1,[]))
            
            yearlyData.append((2012, 2,[]))
            yearlyData.append((2014, 1,[]))
            yearlyData.append((2017, 1,[]))
            
            yearlyData.append((1992, 1,[]))
            
            yearlyData.append((1953, 1,[]))
            yearlyData.append((1957, 1,[]))


            // Sort artists by count in descending order
            self.topDecades = decadeData.sorted { $0.1 > $1.1 }
            self.topYears = yearlyData.sorted { $0.0 < $1.0 }
            
            
        }
        
    }
    
    func fetchYearsByDecade(decade: Int) -> (Int, Int){
        let i = topYears.firstIndex(where: { ($0.0 / 10) * 10 == decade})

        let j = topYears.lastIndex(where: { ($0.0 / 10) * 10 == decade})

        return (i!, j!)

    }
    
    
    init(viewModel: LibraryViewModel) {
            self.viewModel = viewModel
            fetchTopArtists()
            fetchTopGenres()
            fetchTopYears()
    }
    
}


