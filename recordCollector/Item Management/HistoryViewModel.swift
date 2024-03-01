//
//  HistoryViewModel.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/24/24.
//

import Foundation
import SwiftUI
import FirebaseDatabase

class HistoryViewModel: ObservableObject {
    @Published var allHistory = [HistoryItem]()
    
    let maxEntries = 150 // Maximum allowed history entries
    
    private func addNewHistoryItem(id:String,date:Date,type:String,recordID:String){
        let newItem = HistoryItem(id:id,date:date,type:type,recordID:recordID)
        allHistory.append(newItem)
        allHistory.sort { $0.date > $1.date }
    }
    
    func clearRecordIDInstances(recordID: String) async{
        print("removing from history elements")
        
        let ref: DatabaseReference! = Database.database().reference()
        for historyItem in allHistory{
            if historyItem.recordID == recordID{
                do{
                    try await ref.child("History").child(historyItem.id).removeValue()
                } catch{
                    print("Error deleting historyItem \(historyItem.id)")
                }
            }
        }
        
        allHistory = allHistory.filter { $0.recordID != recordID }
    }
    
    
    
    func uploadNewHistoryItem(type:String,recordID:String){
        let id = UUID().uuidString
        
        let ref: DatabaseReference! = Database.database().reference()
        
        let now = Date.now
        let dateString = Date.dateToString(date: now,format:"MM-dd-yyyy HH:mm:ss")
        
        ref.child("History").child(id).child("date").setValue(dateString)
        ref.child("History").child(id).child("type").setValue(type)
        ref.child("History").child(id).child("recordID").setValue(recordID)
        
        addNewHistoryItem(id:id,date:now,type:type,recordID:recordID)
        
        // Check if the number of entries exceeds the maximum allowed
        if self.allHistory.count > maxEntries {
            // Sort the historyData by date in ascending order
            let sortedHistory = self.allHistory.sorted { $0.date < $1.date }

            // Identify the oldest entry
            if let oldestEntry = sortedHistory.first {
                // Delete the oldest entry
                Task {
                    await deleteHistoryItem(id: oldestEntry.id)
                }
            }
        }
        
    }
    
    private func cleanExcessEntries() async {
        // Check if the number of entries exceeds the maximum allowed
        if allHistory.count > maxEntries {
            // Calculate the number of excess entries
            let excessEntriesCount = allHistory.count - maxEntries

            // Identify the oldest entries (now the last elements in the array)
            let oldestEntries = Array(allHistory.suffix(excessEntriesCount))

            // Remove the oldest entries from the end of the array
            allHistory.removeLast(excessEntriesCount)

            // Delete the oldest entries from the remote database
            for entry in oldestEntries {
                await deleteHistoryItem(id: entry.id)
            }
        }
    }
    
    func deleteHistoryItem(id:String) async{
        let ref: DatabaseReference! = Database.database().reference()
        
        self.allHistory.removeAll(where: { $0.id == id })
        
        do{
            try await ref.child("History").child(id).removeValue()
        } catch{
            print("Error deleting history item \(id)")
        }
    }
    
    // Fetch data from db and store in local library
    func fetchData(completion: @escaping () -> Void) {
        print("PERFORMING HISTORY FETCH")
        let allHistory = Database.database().reference().child("History")

        allHistory.observeSingleEvent(of: .value, with: { [self] snapshot in
            let dispatchGroup = DispatchGroup()
            
            for child in snapshot.children {
                
                let snap = child as! DataSnapshot
                let elementDict = snap.value as! [String: String]
                
                let type = elementDict["type"]!
                let recordID = elementDict["recordID"]!
                    
                let date = String.stringToDate(from: elementDict["date"]!, format:"MM-dd-yyyy HH:mm:ss") ?? Date.now
                
                let id = snap.key
                
                // Add record to local library
                dispatchGroup.notify(queue: .main) {
                    self.addNewHistoryItem(id: id,date:date,type:type,recordID:recordID)
                }

            }
            dispatchGroup.notify(queue: .main) {
                // Call cleanExcessEntries function after fetching all data
                Task {
                    await self.cleanExcessEntries()
                    completion()
                }
            }
        })
    }
    
    
}
