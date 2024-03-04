//
//  StoreViewModel.swift
//  recordCollector
//
//  Created by Hannah Adams on 3/1/24.
//

import Foundation
import SwiftUI
import FirebaseDatabase
import FirebaseStorage
import MapKit

class StoreViewModel: ObservableObject {
    @Published var allStores: [String:RecordStore] = [:]
    @Published var topStores: [RecordStore] = []
    @Published var usedTotal: Int = 0
    @Published var onlineTotal: Int = 0
    
    func changeStoreAddress(storeName: String, address: String){
        let ref: DatabaseReference! = Database.database().reference()
        ref.child("Stores").child(storeName).setValue(address)
        
        self.allStores[storeName]!.addressString = address
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.forwardGeocoding(address: address) { geocodedLocation in
            self.allStores[storeName]!.location = geocodedLocation?.coordinate
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            // Update the topStores whenever allStores changes
            self.topStores = self.allStores.values.sorted { (value1, value2) in
                let count1 = value1.recordIDs.count
                let count2 = value2.recordIDs.count
                return count1 > count2
            }
        }
    }
    
    func refreshStoreDistribution(recordLibrary:[RecordItem]){
        var usedCount: Int = 0
        var onlineCount: Int = 0
        for record in recordLibrary{
            if record.store != ""{
                if var store = self.allStores[record.store] {
                    // Optional binding to safely unwrap the optional value

                    store.recordIDs.insert(record.id)
                    self.allStores[record.store] = store

                    if store.addressString == "Online" {
                        onlineCount += 1
                    }
                }
            }
            if record.isUsed{
                usedCount += 1
            }
        }
        self.usedTotal = usedCount
        self.onlineTotal = onlineCount
        
        // Remove stores with no corresponding RecordItem instances
//        self.removeEmptyStores()

        // Update topStores
        self.topStores = self.allStores.values.sorted { $0.recordIDs.count > $1.recordIDs.count }
    }


    func removeEmptyStores() {
        for (storeName,recordStore) in self.allStores{
            if recordStore.recordIDs.isEmpty{
                print("Removing: ", storeName)
                removeStoreFromFirebase(storeName: storeName)
            }
        }

    }

    func removeStoreFromFirebase(storeName: String) {
        let ref: DatabaseReference! = Database.database().reference()

        // Remove the store locally
        self.allStores[storeName] = nil

        // Remove the store from Firebase
        ref.child("Stores").child(storeName).removeValue()
    }
    
    func addNewStore(storeName:String, address: String){

        // Do nothing if no location available
        if storeName == ""{
            return
        }
        
        // Do nothing if already a valid location
        if allStores[storeName] != nil{
            // Don't do anything if already exists
            print("Name in all stores, ", allStores[storeName]!.id)
            return
        }
        
        // Add local library element for UI update before location available
        let recordStore = RecordStore(id: storeName, addressString: address)
        self.allStores[storeName] = recordStore
        
        // Add new location to db
        let ref: DatabaseReference! = Database.database().reference()
        ref.child("Stores").child(storeName).setValue(address)
        
        // Add new location to library
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.forwardGeocoding(address: address) { geocodedLocation in
            
            // Add address to current store
            self.allStores[storeName]!.location = geocodedLocation?.coordinate
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            // Update the topStores whenever allStores changes
            self.topStores = self.allStores.values.sorted { (value1, value2) in
                let count1 = value1.recordIDs.count
                let count2 = value2.recordIDs.count
                return count1 > count2
            }
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
    
    // Fetch data from db and store in local library
    func fetchStoreData(completion: @escaping () -> Void) {
        print("PERFORMING STORES FETCH")
        let allStores = Database.database().reference().child("Stores")

        allStores.observeSingleEvent(of: .value, with: {snapshot in
            let dispatchGroup = DispatchGroup()
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                
                let storeName = snap.key 
                let address = snap.value as! String
                
                dispatchGroup.enter()

                self.forwardGeocoding(address: address) { geocodedLocation in
                    if self.allStores[storeName] != nil {
                        // Store name already exists, overwrite location
                        self.allStores[storeName]!.location = geocodedLocation?.coordinate
                    } else {
                        // Store name doesn't exist, create a new RecordStore item
                        let recordStore = RecordStore(id: storeName, addressString: address, location: geocodedLocation?.coordinate, recordIDs: [])
                        self.allStores[storeName] = recordStore
                    }

                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                Task {
                    completion()
                }
            }
        })
    }
    
    
}
