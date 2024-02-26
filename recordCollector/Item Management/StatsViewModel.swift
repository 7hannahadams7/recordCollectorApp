//
//  StatsViewModel.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/11/24.
//

import Foundation
import SwiftUI
import FirebaseDatabase
import MapKit

struct RecordStore: Identifiable {
    var id: String
    var name: String
    var addressString: String
    var location: CLLocationCoordinate2D?
    var recordIDs: [String]
}

class StatsViewModel: ObservableObject {
//    @ObservedObject var viewModel: LibraryViewModel
    
    @Published var topArtists: [(artist: String, amount: Int, records: [String])] = []
    @Published var topGenres: [(genre: String, amount: Int, records: [String])] = []
    @Published var topDecades: [(decade: Int, amount: Int, records: [String])] = []
    @Published var topYears: [(year: Int, amount: Int, records: [String])] = []
    @Published var topStores: [RecordStore] = []

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

            // Sort artists by count in descending order
            self.topDecades = decadeData.sorted { $0.1 > $1.1 }
            self.topYears = yearlyData.sorted { $0.0 < $1.0 }
            
            
        }
        
    }
    
    func forwardGeocoding(address: String, completion: @escaping (CLLocation?) -> Void) {
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                print("Failed to retrieve location with error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let placemark = placemarks?.first, let location = placemark.location else {
                print("No matching location found")
                completion(nil)
                return
            }

            completion(location)
        }
    }
    
    func fetchYearsByDecade(decade: Int) -> [(Int, Int, [String])]{
        // Return all instances of records within the specified decade
         
        var yearsInDecade: [(Int, Int, [String])] = []
        for year in topYears{
            if (year.0 / 10) * 10 == decade{
                yearsInDecade.append(year)
            }
        }

        return yearsInDecade

    }
    
    func fetchStoreCoordinates() {
        let recordsRef = Database.database().reference().child("Records")

        recordsRef.observeSingleEvent(of: .value) { snapshot in
            var allStores: [RecordStore] = []
            let group = DispatchGroup()

            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let elementDict = snap.value as! [String: Any]

                if let boughtFromDict = elementDict["boughtFrom"] as? [String: String],
                   let storeName = boughtFromDict["storeName"],
                   let location = boughtFromDict["location"] {

                    group.enter()

                    self.forwardGeocoding(address: location) { geocodedLocation in
                        defer {
                            group.leave()
                        }

                        // Check if the storeName already exists in allStores
                        if let existingStoreIndex = allStores.firstIndex(where: { $0.name == storeName }) {
                            // Store name already exists, append record ID to the existing item
                            allStores[existingStoreIndex].recordIDs.append(snap.key)
                        } else {
                            // Store name doesn't exist, create a new RecordStore item
                            let recordStore = RecordStore(id: UUID().uuidString, name: storeName, addressString: location, location: geocodedLocation?.coordinate, recordIDs: [snap.key])
                            allStores.append(recordStore)
                        }
                    }
                }
            }

            group.notify(queue: .main) {
                self.topStores = allStores.sorted { $0.recordIDs.count > $1.recordIDs.count }
            }
        }
    }
    
    
    init(/*viewModel: LibraryViewModel*/) {
//        self.viewModel = viewModel
        fetchTopArtists()
        fetchTopGenres()
        fetchTopYears()
        fetchStoreCoordinates()
    }
    
    func refreshData(){
        fetchTopArtists()
        fetchTopGenres()
        fetchTopYears()
        fetchStoreCoordinates()
    }
    
}


