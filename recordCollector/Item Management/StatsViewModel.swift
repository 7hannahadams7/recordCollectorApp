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

class StatsViewModel: ObservableObject {
    @Published var topArtists: [StatsNameItem] = []
    @Published var topGenres: [StatsNameItem] = []
    @Published var topDecades: [StatsValueItem] = []
    @Published var topYears: [StatsValueItem] = []
    
    @Published var topStores: [RecordStore] = []
    
    @Published var usedTotal: Int = 0
    @Published var onlineTotal: Int = 0
    
    func pullStatsFromLibrary(recordLibrary: [RecordItem]){
        var artistData: [StatsNameItem] = []
        var genreData: [StatsNameItem] = []
        var decadeData: [StatsValueItem] = []
        var yearlyData: [StatsValueItem] = []
        var usedCount = 0
        
        for record in recordLibrary{

            let recordID = record.id
            if let index = artistData.firstIndex(where: { $0.name == record.artist }) {
                // Artist already exists in the array, update count and add record ID
                artistData[index].amount += 1
                artistData[index].records.append(recordID)
            } else {
                // New artist, add to the array
                artistData.append(StatsNameItem(id:UUID(),name: record.artist, amount: 1, records: [recordID]))
            }
            
            for genre in record.genres{
                if let index = genreData.firstIndex(where: {$0.name == genre}){
                    genreData[index].amount += 1
                    genreData[index].records.append(recordID)
                }else{
                    genreData.append(StatsNameItem(id:UUID(),name:genre,amount:1,records:[recordID]))
                }
            }
            
            if let index = yearlyData.firstIndex(where: { $0.value == record.releaseYear}){
                yearlyData[index].amount += 1
                yearlyData[index].records.append(recordID)
            } else {
                yearlyData.append(StatsValueItem(id:UUID(),value:record.releaseYear, amount: 1, records: [recordID]))
            }

            let decade = (record.releaseYear/10)*10
            if let index = decadeData.firstIndex(where: { $0.value == decade}){
                decadeData[index].amount += 1
                decadeData[index].records.append(recordID)
            } else {
                decadeData.append(StatsValueItem(id:UUID(),value:decade, amount: 1, records: [recordID]))
            }
            
            if record.isUsed{
                usedCount += 1
            }
            
            
        }
        self.topArtists = artistData.sorted { $0.amount > $1.amount }
        self.topGenres = genreData.sorted { $0.amount > $1.amount }
        self.topDecades = decadeData.sorted { $0.amount > $1.amount }
        self.topYears = yearlyData.sorted { $0.value < $1.value }
        self.usedTotal = usedCount

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
    
    func fetchYearsByDecade(decade: Int) -> [StatsValueItem]{
        // Return all instances of records within the specified decade
         
        var yearsInDecade: [StatsValueItem] = []
        for year in topYears{
            if (year.value / 10) * 10 == decade{
                yearsInDecade.append(year)
            }
        }
        return yearsInDecade
    }
    
//    func fetchStoreCoordinates() {
//        let recordsRef = Database.database().reference().child("Records")
//
//        recordsRef.observeSingleEvent(of: .value) { snapshot in
//            var allStores: [RecordStore] = []
//            var onlineCount: Int = 0
//            let group = DispatchGroup()
//
//            for child in snapshot.children {
//                let snap = child as! DataSnapshot
//                let elementDict = snap.value as! [String: Any]
//
//                if let boughtFromDict = elementDict["boughtFrom"] as? [String: String],
//                   let storeName = boughtFromDict["storeName"],
//                   let location = boughtFromDict["location"] {
//
//                    if location == "Online"{
//                        onlineCount += 1
//                    }
//                    group.enter()
//
//                    self.forwardGeocoding(address: location) { geocodedLocation in
//                        defer {
//                            group.leave()
//                        }
//
//                        // Check if the storeName already exists in allStores
//                        if let existingStoreIndex = allStores.firstIndex(where: { $0.name == storeName }) {
//                            // Store name already exists, append record ID to the existing item
////                            allStores[existingStoreIndex].recordIDs.append(snap.key)
//                        } else {
//                            // Store name doesn't exist, create a new RecordStore item
//                            let recordStore = RecordStore(id: UUID().uuidString, name: storeName, addressString: location, location: geocodedLocation?.coordinate, recordIDs: [snap.key])
//                            allStores.append(recordStore)
//                        }
//                    }
//                }
//            }
//
//            group.notify(queue: .main) {
//                self.topStores = allStores.sorted { $0.recordIDs.count > $1.recordIDs.count }
//                self.onlineTotal = onlineCount
//            }
//        }
//    }
    
    func refreshData(recordLibrary:[RecordItem]){
        pullStatsFromLibrary(recordLibrary:recordLibrary)
//        fetchStoreCoordinates()
    }
    
}


