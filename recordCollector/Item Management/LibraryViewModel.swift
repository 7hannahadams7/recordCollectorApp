//
//  LibraryViewModel.swift
//  test3
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
    
    @Published var fullGenres = Set<String>()
    @Published var fullArtists = Set<String>()
    
    @Published var isImagePickerPresented: Bool = false
    @Published var capturedCoverImage: UIImage? = nil
    @Published var capturedLPImage: UIImage? = nil
    
    @Published var whichPhoto: String = "Cover"
    
    @Published var sortingFactor: SortingFactor = .artist {
        didSet {
            sortRecords()
        }
    }
    
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

    // Upload new entry to database and local library
    func uploadRecord(recordName: String, artistName: String, releaseYear: Int, genres: [String], dateAdded: String, isBand: Bool){
        // Uploading New Instance of Record Data to Database

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
        
        // Create new item in local library with data (leaves photo empty)
        addNewRecord(id: id, name: recordName, artist: artistName, releaseYear: releaseYear, genres: genres, dateAdded: dateAdded, isBand: isBand)

        // Attempt photo upload, will handle adding to db if photo available
        uploadPhoto(id: id, image: self.capturedCoverImage,type:"Cover")
        uploadPhoto(id: id, image: self.capturedLPImage,type:"Disc")
        
        print("Added New Record, ID #: ", id)
        
    }
    
    // Adds new entry to local library
    func addNewRecord(id: String, name: String, artist: String, releaseYear: Int, coverPhoto: UIImage? = UIImage(named:"TakePhoto"), discPhoto: UIImage? = UIImage(named:"TakePhoto"),genres:[String],dateAdded:String, isBand:Bool) {
        // Add New Instance of Record Data to Local Library
        
        let newItem = RecordItem(id: id, name: name, artist: artist, coverPhoto:coverPhoto!, discPhoto: discPhoto!, releaseYear: releaseYear,genres:genres, dateAdded: dateAdded, isBand:isBand)
        
        // Add to array for library sorting, add to dictionary for fetching
        recordLibrary.append(newItem)
        recordDictionaryByID[id] = newItem
    }
    
    // Upload photo to storage, link to db, add to local library entry
    func uploadPhoto(id: String, image: UIImage?, type: String) -> Void{
//        print("Attempting Image Upload")
        let ref: DatabaseReference! = Database.database().reference()
        
        // Check selected image property not nil
        guard image != nil else{
//            print("No Image Uploaded, ID #: ", id)
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
        
        // Create storage reference
        let storageRef = Storage.storage().reference()
        
        // Turn image into jpeg data
        let imageData = image!.jpegData(compressionQuality: 0.5)
        
        // Check that we were able to convert it to data
        guard imageData != nil else{
//            print("ERROR Cannot Convert Image, ID #: ", id)
            return
        }
        
        // Specify the file path and name
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
//                print("Image Upload Successful, ID #: ", id)
                
            }else{
//                print("ERROR Image Upload, ID #: ", id)
                return
            }
        }
        
    }
    
    // Edit existing entry in db and local library
    func editRecordEntry(id: String,recordName: String? = nil, artistName: String? = nil, releaseYear: Int? = nil, newPhoto: Bool, genres: [String]? = nil, dateAdded: String? = nil, isBand: Bool? = nil){
        // Edit values of current db Item
        
        print("Editing Entry: ", id)
        let ref: DatabaseReference! = Database.database().reference()
        
        // Pulling item from local library by id, making changes in local library
        if let recordIndex = self.recordLibrary.firstIndex(where: { $0.id == id }){
            // Re-value child elements
            if artistName != nil{
                self.recordLibrary[recordIndex].artist = artistName!
                self.recordDictionaryByID[id]?.artist = artistName!
            }
            if artistName != nil{
                self.recordLibrary[recordIndex].name = recordName!
                self.recordDictionaryByID[id]?.name = recordName!
            }
            if releaseYear != nil{
                self.recordLibrary[recordIndex].releaseYear = releaseYear!
                self.recordDictionaryByID[id]?.releaseYear = releaseYear!
            }
            if dateAdded != nil{
                self.recordLibrary[recordIndex].dateAdded = dateAdded!
                self.recordDictionaryByID[id]?.dateAdded = dateAdded!
            }
            if isBand != nil{
                self.recordLibrary[recordIndex].isBand = isBand!
                self.recordDictionaryByID[id]?.isBand = isBand!
            }
            if genres != nil{
                self.recordLibrary[recordIndex].genres = genres!
                self.recordDictionaryByID[id]?.genres = genres!
            }
            
            sortRecords()
            
        }
        
        // Attempt to upload photo if new photo available, uploadPhoto adds the photo to the database if possible
        if newPhoto{
            uploadPhoto(id: id, image: self.capturedCoverImage,type:"Cover")
            uploadPhoto(id: id, image: self.capturedLPImage,type:"Disc")
        }
        
        
        // Change db values
        if artistName != nil{
            ref.child("Records").child(id).child("artist").setValue(String(artistName!))
        }
        if artistName != nil{
            ref.child("Records").child(id).child("name").setValue(String(recordName!))
        }
        if releaseYear != nil{
            ref.child("Records").child(id).child("releaseYear").setValue(releaseYear!)
        }
        if dateAdded != nil{
            ref.child("Records").child(id).child("dateAdded").setValue(dateAdded!)
        }
        if isBand != nil{
            ref.child("Records").child(id).child("isBand").setValue(isBand!)
        }
        
        // Add new genres and deleted any removed from list by user
        if genres != nil{
            if let previousGenres = self.recordDictionaryByID[id]?.genres{
                // Add new
                for genre in genres!{
                    // Add new genre child (repeats handled)
                    ref.child("Records").child(id).child("genres").child(genre).setValue(true)
                }
                // Remove old
                for genre in previousGenres{
                    if !genres!.contains(genre){
                        ref.child("Records").child(id).child("genres").child(genre).removeValue()
                    }
                }
            }
        }

        print("Updated Record, ID #: ", id)
    }
    
    // Delete entry locally and from db, and images from storage
    func deleteRecordEntry(id: String) async {
        print("Deleting Entry: ", id)
        let ref: DatabaseReference! = Database.database().reference()
        let storageRef = Storage.storage().reference()
        
        // Create a reference to the file to delete
        let coverImageRef = storageRef.child("recordImages").child(id + ".jpg")
        let discImageRef = storageRef.child("discImages").child(id + ".jpg")
        
        // Remove from local library
        if let recordIndex = self.recordLibrary.firstIndex(where: { $0.id == id }){
            self.recordLibrary.remove(at: recordIndex)
            self.recordDictionaryByID[id] = nil
        }

        do {
          // Delete the files
            try await coverImageRef.delete()
            try await discImageRef.delete()
        } catch {
          print("No image file to delete from storage")
        }
        do{
            try await ref.child("Records").child(id).removeValue()
        } catch{
            
        }
    }
    
    
    // MARK: - Library Data Initializing (Fetching, Sorting, etc.)
    
    // Fetch data from db and store in local library
    private func fetchData(completion: @escaping () -> Void) {
        print("PERFORMING FETCH")
        let allRecords = Database.database().reference().child("Records")
        let storageRef = Storage.storage().reference()

        allRecords.observeSingleEvent(of: .value, with: { [self] snapshot in
            let dispatchGroup = DispatchGroup()

            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let elementDict = snap.value as! [String: Any]

                let artist = elementDict["artist"]
                
                let name = elementDict["name"]
                let releaseYear = elementDict["releaseYear"]
                let dateAdded = elementDict["dateAdded"]
                let isBand = elementDict["isBand"] as! Bool

                var coverPhoto: UIImage?
                var discPhoto: UIImage?

                var genres: [String] = []

                if let genresDict = elementDict["genres"] as? [String: Bool] {
                    for (genre, value) in genresDict {
                        if value {
                            genres.append(genre)
                        }
                    }
                }

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

                dispatchGroup.notify(queue: .main) {
//                    print("IN QUEUE")
                    if let discPhoto = discPhoto, let coverPhoto = coverPhoto {
//                        print("Adding both")
                        self.addNewRecord(id: snap.key, name: name as! String, artist: artist as! String, releaseYear: releaseYear as! Int, coverPhoto: coverPhoto, discPhoto: discPhoto, genres: genres,dateAdded:dateAdded as! String,isBand: isBand)
                    } else if let discPhoto = discPhoto {
//                        print("Adding disc")
                        self.addNewRecord(id: snap.key, name: name as! String, artist: artist as! String, releaseYear: releaseYear as! Int, discPhoto: discPhoto, genres: genres,dateAdded:dateAdded as! String,isBand: isBand)
                    } else if let coverPhoto = coverPhoto {
//                        print("Adding cover")
                        self.addNewRecord(id: snap.key, name: name as! String, artist: artist as! String, releaseYear: releaseYear as! Int, coverPhoto: coverPhoto, genres: genres,dateAdded:dateAdded as! String, isBand: isBand)
                    } else {
//                        print("No Photo")
                        self.addNewRecord(id: snap.key, name: name as! String, artist: artist as! String, releaseYear: releaseYear as! Int, genres: genres,dateAdded:dateAdded as! String,isBand: isBand)
                    }
                    completion()
                }
            }
        })
    }

    func filteredLibrary(sortingFactor: String, sortingDirection: Bool, filteredGenres: [String]) -> (records: [RecordItem], headers: [String]){
        // SortingFactor sort is handled by self.sortRecords() and is automatic from case change in MyLibraryView
        
        // Filter and Set Directions
        let filteredRecords = sortingDirection ?  self.recordLibrary.filter({$0.genres.contains{Set(filteredGenres).contains($0)}}) :
        self.recordLibrary.filter({$0.genres.contains{Set(filteredGenres).contains($0)}}).reversed()
        
        // Headers pulled from filtered library
        let headers = sortingDirection ? sortingHeaderFunction(filteredRecords:filteredRecords, sortingFactor:sortingFactor) : sortingHeaderFunction(filteredRecords:filteredRecords, sortingFactor:sortingFactor).reversed()
        
        return (filteredRecords, headers)
    }
    
    // Given a sorting factor, header, and recordItem, determine if the record falls under the header or not
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
    
    func gatherAllFilterOptions(){
        for record in self.recordLibrary{
            self.fullArtists.insert(record.artist)
            for genre in record.genres{
                self.fullGenres.insert(genre)
            }
        }
    }
    
    private func sortingHeaderFunction(filteredRecords: [RecordItem], sortingFactor: String) -> [String]{
        var headers: [String] = []
        for record in filteredRecords{
            if sortingFactor == "Artist"{
                var char = ""
                if record.isBand {
                    let components = record.artist.components(separatedBy: " ")
                    char = String((components.first == "The" ? components.dropFirst().joined(separator: " ") : components.first ?? "z").first!)
                } else {
                    char = String((record.artist.components(separatedBy: " ").last ?? "z").first!)
                }
                if !headers.contains(char){
                    headers.append(char)
                }
            }else if sortingFactor == "Album"{
                if let character = record.name.first, !headers.contains(String(character)) {
                    headers.append(String(character))
                }
            }else if sortingFactor == "Release Year"{
                if !headers.contains(String(record.releaseYear)){
                    headers.append(String(record.releaseYear))
                }
            }else{
                if !headers.contains(record.dateAdded){
                    headers.append(record.dateAdded)
                }
            }
        }
        
        if sortingFactor == "Date Added"{
            let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy"
            headers.sort {
                // Sort chronologically by actual date
                guard let date1 = String.stringToDate(from: $0),
                      let date2 = String.stringToDate(from: $1) else {
                    return false // Handle invalid date strings as needed
                }
                return date1 > date2
            }
            return headers
        }else{
            return headers.sorted(by: {$0 < $1})
        }
        
    }
    
    private func sortRecords() {
        // Sorting of local library, runs on all refreshes, on change of sortingFactor case in MyLibraryView and on init
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
    
    func checkArtistHeaderMatch(record: RecordItem, header: String) -> Bool{
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
    
    func fetchPhotoByID(id: String) -> UIImage? {
        if let recordItem = recordDictionaryByID[id] {
            return recordItem.coverPhoto
        }
//        print("Couldn't find id in dictionary")
        return UIImage(named:"TakePhoto")  // Return defaultIm if the ID is not found
    }
    
    func refreshData(){
        print("REFRESHING DATA")
        recordLibrary = []
        recordDictionaryByID = [:]
        fetchData{
            self.sortRecords()
            self.gatherAllFilterOptions()
        }
    }
    
    
    
}
