//
//  LibraryViewModel.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/8/24.
//

import Foundation
import SwiftUI
import FirebaseDatabase
import FirebaseStorage

class LibraryViewModel: ObservableObject {
    @Published var recordLibrary = [RecordItem]()
    @Published var recordDictionaryByID: [String: RecordItem] = [:]
    
    @ObservedObject var historyViewModel = HistoryViewModel()
    
    @Published var fullGenres = Set<String>()
    @Published var fullArtists = Set<String>()
    @Published var fullStores: [String:String] = [:]
    @Published var fullLocations = Set<String>()
    
    @Published var isImagePickerPresented: Bool = false
    @Published var capturedCoverImage: UIImage? = nil
    @Published var capturedLPImage: UIImage? = nil
    
    @Published var whichPhoto: String = "Cover"
    
    @Published var isRefreshing: Bool = false
    
    // Re-sorting local library on change of sorting factor
    @Published var sortingFactor: SortingFactor = .artist {
        didSet {
            sortRecords()
        }
    }
    
    // MyLibrary sorting factors
    enum SortingFactor: String, CaseIterable {
        case dateAdded = "Date Added"
        case artist = "Artist"
        case releaseYear = "Release Year"
        case album = "Album"
    }
    
    // MARK: - Photo Actions
    func resetPhoto(){
//        print("Resetting Captured Photo")
        capturedLPImage = nil
        capturedCoverImage = nil
    }
    
    func capturePhoto() {
//        print("capturePhoto selected")
        isImagePickerPresented = true
    }

    func imagePickerCallback(image: UIImage?) {
        if whichPhoto == "Cover"{
            capturedCoverImage = image
        }else{
            capturedLPImage = image
        }
        isImagePickerPresented = false
    }
    
    // MARK: - Record Updating/Init

    // Upload new entry to database and local library, called via AddRecordView
    func uploadRecord(recordName: String, artistName: String, releaseYear: Int, genres: [String], dateAdded: String, isBand: Bool, storeName: String, location: String){
        // UUID of entry
        let id = UUID().uuidString
        
        let ref: DatabaseReference! = Database.database().reference()
        
        // Add child elements
        ref.child("Records").child(id).child("artist").setValue(artistName)
        ref.child("Records").child(id).child("name").setValue(recordName)
        ref.child("Records").child(id).child("releaseYear").setValue(releaseYear)
        ref.child("Records").child(id).child("dateAdded").setValue(dateAdded)
        ref.child("Records").child(id).child("isBand").setValue(isBand)
        for genre in genres{
            let path = "\(genre)"
            ref.child("Records").child(id).child("genres").child(path).setValue(true)
        }
        if storeName != ""{
            ref.child("Records").child(id).child("boughtFrom").child("storeName").setValue(storeName)
            ref.child("Records").child(id).child("boughtFrom").child("location").setValue(location)
        }
        
        // Create new item in local library with data (leaves photo empty)
        addNewRecord(id: id, name: recordName, artist: artistName, releaseYear: releaseYear, genres: genres, dateAdded: dateAdded, isBand: isBand, storeName: storeName, location: location)

        // Attempt photo upload, will handle adding to db if photo available
        uploadAddPhoto(id: id, image: self.capturedCoverImage,type:"Cover")
        uploadAddPhoto(id: id, image: self.capturedLPImage,type:"Disc")
        
        print("Added New Record, ID #: ", id)
        
        self.historyViewModel.uploadNewHistoryItem(type: "Add", recordID: id)
    }
    
    // Adds new entry to local library, called via AddRecordView and in self.fetch()
    func addNewRecord(id: String, name: String, artist: String, releaseYear: Int, coverPhoto: UIImage? = UIImage(named:"TakePhoto"), discPhoto: UIImage? = UIImage(named:"TakePhoto"),genres:[String],dateAdded:String, isBand:Bool, storeName: String, location: String) {
        // Add New Instance of Record Data to Local Library
        
        
        var newItem = RecordItem(id: id, name: name, artist: artist, coverPhoto:coverPhoto!, discPhoto: discPhoto!, releaseYear: releaseYear,genres:genres, dateAdded: dateAdded, isBand:isBand)
        if storeName != ""{
            newItem.store = (storeName, location)
        }
        
        // Add to array for library sorting, add to dictionary for fetching
        recordLibrary.append(newItem)
        recordDictionaryByID[id] = newItem
        
        // Update current filter options when adding new item to array
        fullArtists.insert(artist)
        for genre in genres{
            fullGenres.insert(genre)
        }
        
        if storeName != ""{
            fullStores[storeName] = location
            fullLocations.insert(location)
        }
    }
    
    // Upload photo to storage, link to db, add to local library entry, called in uploads and edits
    func uploadAddPhoto(id: String, image: UIImage?, type: String) -> Void{

        let ref: DatabaseReference! = Database.database().reference()
        let storageRef = Storage.storage().reference()
        
        // Check selected image property not nil
        guard image != nil else{
            print("No Image Uploaded, ID #: ", id)
            return
        }
        
        // Replace image of current item in local library
        if let recordIndex = self.recordLibrary.firstIndex(where: { $0.id == id }){
            // Forced unwrap because checked image wasn't nil
            if type == "Cover"{
                self.recordLibrary[recordIndex].coverPhoto = image!
                self.recordDictionaryByID[id]?.coverPhoto = image!
            }else{
                self.recordLibrary[recordIndex].discPhoto = image!
                self.recordDictionaryByID[id]?.discPhoto = image!
            }
        }
        
        // Turn image into jpeg data
        let imageData = image!.jpegData(compressionQuality: 0.5)
        
        // Check that we were able to convert it to data
        guard imageData != nil else{
            return
        }
        
        // Specify the storage file path and name
        var path = ""
        if type == "Cover"{
            path = "recordImages/" + id + ".jpg"
        }else{
            path = "discImages/" + id + ".jpg"
        }
        let fileRef = storageRef.child(path)
        
        // Upload data
        _ = fileRef.putData(imageData!, metadata:nil){
            metadata, error in
            
            // Check no errors
            if error == nil && metadata != nil{
                // Add URL to DB entry
                if type == "Cover"{
                    ref.child("Records").child(id).child("imageURL").setValue(path)
                }else{
                    ref.child("Records").child(id).child("discImageURL").setValue(path)
                }
                
            }else{
                return
            }
        }
        
    }
    
    // Edit existing entry in db and local library, called via ShowRecordView
    func editRecordEntry(id: String,recordName: String, artistName: String, releaseYear: Int, newCoverPhoto: Bool, newDiskPhoto: Bool, genres: [String], dateAdded: String, isBand: Bool, storeName: String, location: String){

        print("Editing Entry: ", id)
        let ref: DatabaseReference! = Database.database().reference()
        
        // Pulling item from local library by id, making changes in local library
        if let recordIndex = self.recordLibrary.firstIndex(where: { $0.id == id }){

            self.recordLibrary[recordIndex].artist = artistName
            self.recordDictionaryByID[id]?.artist = artistName

            self.recordLibrary[recordIndex].name = recordName
            self.recordDictionaryByID[id]?.name = recordName

            self.recordLibrary[recordIndex].releaseYear = releaseYear
            self.recordDictionaryByID[id]?.releaseYear = releaseYear

            self.recordLibrary[recordIndex].dateAdded = dateAdded
            self.recordDictionaryByID[id]?.dateAdded = dateAdded

            self.recordLibrary[recordIndex].isBand = isBand
            self.recordDictionaryByID[id]?.isBand = isBand

            self.recordLibrary[recordIndex].genres = genres
            self.recordDictionaryByID[id]?.genres = genres
            
            if storeName != nil{
                self.recordLibrary[recordIndex].store = (storeName,location)
                self.recordDictionaryByID[id]?.store = (storeName,location)
            }
            
            // Re-sort with new edited elements
            sortRecords()
            
        }
        
        // Attempt to upload photo if new photo available, uploadPhoto adds the photo to the database if possible
        if newCoverPhoto{
            uploadAddPhoto(id: id, image: self.capturedCoverImage,type:"Cover")
        }
        if newDiskPhoto{
            uploadAddPhoto(id: id, image: self.capturedLPImage,type:"Disc")
        }
        
        
        // Change db values
        ref.child("Records").child(id).child("artist").setValue(String(artistName))
        ref.child("Records").child(id).child("name").setValue(String(recordName))
        ref.child("Records").child(id).child("releaseYear").setValue(releaseYear)
        ref.child("Records").child(id).child("dateAdded").setValue(dateAdded)
        ref.child("Records").child(id).child("isBand").setValue(isBand)

        // Add new genres and deleted any removed from list by user
        if let previousGenres = self.recordDictionaryByID[id]?.genres{
            // Add new
            for genre in genres{
                // Add new genre child (repeats handled)
                ref.child("Records").child(id).child("genres").child(genre).setValue(true)
            }
            // Remove old
            for genre in previousGenres{
                if !genres.contains(genre){
                    ref.child("Records").child(id).child("genres").child(genre).removeValue()
                }
            }
        }
        
        if storeName != ""{
            ref.child("Records").child(id).child("boughtFrom").child("storeName").setValue(storeName)
            ref.child("Records").child(id).child("boughtFrom").child("location").setValue(location)
        }
        
        // Reset and re-gather all filter options when one is edited
        self.gatherAllFilterOptions()

        print("Updated Record, ID #: ", id)
        self.historyViewModel.uploadNewHistoryItem(type: "Edit", recordID: id)
    }
    
    // Delete entry locally and from db, and images from storage, called via ShowRecordView
    func deleteRecordEntry(id: String) async {
        print("Deleting Entry: ", id)
        
        let ref: DatabaseReference! = Database.database().reference()
        let storageRef = Storage.storage().reference()
        
        // Create a reference to the files to delete
        let coverImageRef = storageRef.child("recordImages").child(id + ".jpg")
        let discImageRef = storageRef.child("discImages").child(id + ".jpg")
        
        // Remove from local library
        if let recordIndex = self.recordLibrary.firstIndex(where: { $0.id == id }){
            self.recordLibrary.remove(at: recordIndex)
            self.recordDictionaryByID[id] = nil
        }

        // Attempt cover image delete from storage
        do {
            try await coverImageRef.delete()
        } catch {
          print("No cover image file to delete from storage")
        }
        // Attempt disk image delete from storage
        do {
          // Delete the files
            try await discImageRef.delete()
        } catch {
          print("No disk image file to delete from storage")
        }
        do{
            try await ref.child("Records").child(id).removeValue()
        } catch{
            print("Error deleting record \(id)")
        }
    }
    
    
    // MARK: - Library Data Initializing (Fetching, Local Libraries, etc.)
    
    // Fetch data from db and store in local library
    private func fetchData(completion: @escaping () -> Void) {
        print("PERFORMING FETCH")
        let allRecords = Database.database().reference().child("Records")
        let storageRef = Storage.storage().reference()

        allRecords.observeSingleEvent(of: .value, with: { [self] snapshot in
            let dispatchGroup = DispatchGroup()

            // COMMENT THIS FOR FULL BUILD
            let maxChildrenToFetch = 6
            var childrenCount = 0
            
            for child in snapshot.children {
                // COMMENT FOR FULL BUILD
//                guard childrenCount < maxChildrenToFetch else {
//                    // Break the loop if the maximum number of children is reached
//                    break
//                }
                
                let snap = child as! DataSnapshot
                let elementDict = snap.value as! [String: Any]
                
                let artist = elementDict["artist"] as! String
                
                let name = elementDict["name"] as! String
                let releaseYear = elementDict["releaseYear"] as! Int
                let dateAdded = elementDict["dateAdded"] as! String
                let isBand = elementDict["isBand"] as! Bool
                
                // Set to default images
                var coverPhoto = UIImage(named:"TakePhoto")
                var discPhoto = UIImage(named:"TakePhoto")
                
                var genres: [String] = []
                
                // Pull genres to array
                if let genresDict = elementDict["genres"] as? [String: Bool] {
                    for (genre, value) in genresDict {
                        if value {
                            genres.append(genre)
                        }
                    }
                }
                
                var storeName: String = ""
                var location: String = ""
//                var boughtFrom: [String: String] = ["storeName": "", "location": ""]
                
                if let boughtFromDict = elementDict["boughtFrom"] as? [String: String]{
                    storeName = boughtFromDict["storeName"]!
                    location = boughtFromDict["location"]!
                    print(storeName, location)
                }
                
                // Pull cover image from storage
                if let im = elementDict["imageURL"] {
                    let fileRef = storageRef.child(im as! String)
                    dispatchGroup.enter()
                    fileRef.getData(maxSize: 1 * 1024 * 1024, completion: { data, error in
                        if error == nil, let data = data {
                            coverPhoto = UIImage(data: data)
                        }
                        dispatchGroup.leave()
                    })
                }
                
                // Pull disk image from storage
                if let im = elementDict["discImageURL"] {
                    let fileRef = storageRef.child(im as! String)
                    dispatchGroup.enter()
                    fileRef.getData(maxSize: 1 * 1024 * 1024, completion: { data, error in
                        if error == nil, let data = data {
                            discPhoto = UIImage(data: data)
                        }
                        dispatchGroup.leave()
                    })
                }
                
                // Add record to local library
                dispatchGroup.notify(queue: .main) {
                    //                    print("IN QUEUE")
                    self.addNewRecord(id: snap.key, name: name , artist: artist , releaseYear: releaseYear , coverPhoto: coverPhoto, discPhoto: discPhoto, genres: genres,dateAdded:dateAdded ,isBand: isBand,storeName: storeName, location: location)
                    completion()
                }
                childrenCount += 1
            }
        })
    }
    
    // Reset local libraries and re-fetch and sort data
    func refreshData(){
        print("REFRESHING DATA")
        self.isRefreshing = true
        self.recordLibrary = []
        self.recordDictionaryByID = [:]
        self.fetchData{
            self.sortRecords()
            self.isRefreshing = false
        }
        self.historyViewModel.fetchData {
            print("Fetching history")
        }
    }
    
    // Iterate through library, gather all Genres and Artists in library for Filters
    func gatherAllFilterOptions(){
        for record in self.recordLibrary{
            self.fullArtists.insert(record.artist)
            for genre in record.genres{
                self.fullGenres.insert(genre)
            }
        }
    }
    
    // Used to display images in different views via call
    func fetchPhotoByID(id: String) -> UIImage? {
        if let recordItem = recordDictionaryByID[id] {
            return recordItem.coverPhoto
        }
        return UIImage(named:"TakePhoto")  // Return defaultIm if the ID is not found
    }
    
    // MARK: - Local Library Sorting and Comparator Functions
    
    // Sorting of local library, runs on all refreshes, on change of sortingFactor case in MyLibraryView and on init
    private func sortRecords() {
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
        
        switch sortingFactor {
        case .dateAdded:
            recordLibrary.sort {
                // Sort chronologically by actual date
                guard let date1 = String.stringToDate(from: $0.dateAdded),
                      let date2 = String.stringToDate(from: $1.dateAdded) else {
                    return false // Handle invalid date strings as needed
                }
                return date1 > date2
            }
        case .artist:
            // Sort with consideration for band vs person and exclude leading The
            recordLibrary.sort {
                let isBand1 = $0.isBand
                let isBand2 = $1.isBand

                let name1: String
                let name2: String

                if isBand1 {
                    let components1 = $0.artist.components(separatedBy: " ")
                    name1 = components1.first == "The" ? components1.dropFirst().joined(separator: " ") : components1.first ?? ""
                } else {
                    name1 = $0.artist.components(separatedBy: " ").last ?? ""
                }

                if isBand2 {
                    let components2 = $1.artist.components(separatedBy: " ")
                    name2 = components2.first == "The" ? components2.dropFirst().joined(separator: " ") : components2.first ?? ""
                } else {
                    name2 = $1.artist.components(separatedBy: " ").last ?? ""
                }

                return name1 < name2
            }
        case .releaseYear:
            recordLibrary.sort {
                if $0.releaseYear != $1.releaseYear {
                    return $0.releaseYear < $1.releaseYear
                } else {
                    return $0.artist < $1.artist
                }
            }
        case .album:
            recordLibrary.sort {
                if $0.name != $1.name {
                    return $0.name < $1.name
                } else {
                    return $0.releaseYear < $1.releaseYear
                }
            }
        }
    }
    
    // Given a sorting factor, header, and recordItem, determine if the record falls under the header or not, called in MyLibrary to compare section header
    func headerToItemMatch(sortingFactor:String, header:String, record: RecordItem) -> Bool{
        
        if sortingFactor == "Artist"{
            return checkArtistHeaderMatch(record: record, header: header)
        }else if sortingFactor == "Album"{
            return header.first == record.name.first
        }else if sortingFactor == "Release Year"{
            return header == String(record.releaseYear)
        }else{
            return header == record.dateAdded
        }
        
    }
    
    // Compare function for header to artist name (considers if isBand and excludes 'The')
    private func checkArtistHeaderMatch(record: RecordItem, header: String) -> Bool{
        // Returns whether record aligns with header for Artist Sorting Factor
        var char = ""
        if record.isBand {
            let components = record.artist.components(separatedBy: " ")
            char = String((components.first == "The" ? components.dropFirst().joined(separator: " ") : components.first ?? "z").first!)
        } else {
            char = String((record.artist.components(separatedBy: " ").last ?? "z").first!)
        }
        return char == header
    }

    
}
