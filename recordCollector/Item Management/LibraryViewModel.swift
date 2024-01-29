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
    
    @Published var sortingElementHeaders: (artist: [String], album: [String], releaseYear: [String]) = (artist:[],album:[],releaseYear:[])
    
    @Published var fullGenres = Set<String>()
    
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
//        case dateAdded = "Date Added"
        case artist = "Artist"
        case releaseYear = "Release Year"
        case album = "Album"
    }
    
    // MARK: - Photo Actions
    func resetPhoto(){
        print("Resetting Captured Photo")
        capturedLPImage = nil
        capturedCoverImage = nil
    }
    
    func capturePhoto() {
        print("capturePhoto selected")
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

    func uploadRecord(recordName: String, artistName: String, releaseYear: Int, genres: [String]){
        // Uploading New Instance of Record Data to Database

        // UUID of entry
        let id = UUID().uuidString
        
        let ref: DatabaseReference! = Database.database().reference()
        
        // Add child elements
        ref.child("Records").child(id).child("artist").setValue(String(artistName))
        ref.child("Records").child(id).child("name").setValue(String(recordName))
        ref.child("Records").child(id).child("releaseYear").setValue(releaseYear)
        for genre in genres{
            let path = "\(genre)"
            ref.child("Records").child(id).child("genres").child(path).setValue(true)
        }
        
        // Create new item in local library with data (leaves photo empty)
        addNewRecord(id: id, name: recordName, artist: artistName, releaseYear: releaseYear, genres: genres)

        // Attempt photo upload, will handle adding to db if photo available
        uploadPhoto(id: id, image: self.capturedCoverImage,type:"Cover")
        uploadPhoto(id: id, image: self.capturedLPImage,type:"Disc")
        
        print("Added New Record, ID #: ", id)
        
    }
    
    func addNewRecord(id: String, name: String, artist: String, releaseYear: Int, coverPhoto: UIImage? = UIImage(named:"TakePhoto"), discPhoto: UIImage? = UIImage(named:"TakePhoto"),genres:[String]) {
        // Add New Instance of Record Data to Local Library
        
        let newItem = RecordItem(id: id, name: name, artist: artist, coverPhoto:coverPhoto!, discPhoto: discPhoto!, releaseYear: releaseYear,genres:genres)
        
        // Add to array for library sorting, add to dictionary for fetching
        recordLibrary.append(newItem)
        recordDictionaryByID[id] = newItem
    }
    
    func uploadPhoto(id: String, image: UIImage?, type: String) -> Void{
        print("Attempting Image Upload")
        let ref: DatabaseReference! = Database.database().reference()
        
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
        
        // Create storage reference
        let storageRef = Storage.storage().reference()
        
        // Turn image into jpeg data
        let imageData = image!.jpegData(compressionQuality: 0.5)
        
        // Check that we were able to convert it to data
        guard imageData != nil else{
            print("ERROR Cannot Convert Image, ID #: ", id)
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
                print("Image Upload Successful, ID #: ", id)
                
            }else{
                print("ERROR Image Upload, ID #: ", id)
                return
            }
        }
        
    }
    
    func editRecordEntry(id: String,recordName: String? = nil, artistName: String? = nil, releaseYear: Int? = nil, newPhoto: Bool, genres: [String]? = nil){
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
    private func fetchData(completion: @escaping () -> Void) {
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

                var coverPhoto: UIImage?
                var discPhoto: UIImage?

                var genres: [String] = []

                if let genresDict = elementDict["genres"] as? [String: Bool] {
                    for (genre, value) in genresDict {
                        if value {
                            genres.append(genre)
                            self.fullGenres.insert(genre)
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
                    print("IN QUEUE")
                    if let discPhoto = discPhoto, let coverPhoto = coverPhoto {
                        print("Adding both")
                        self.addNewRecord(id: snap.key, name: name as! String, artist: artist as! String, releaseYear: releaseYear as! Int, coverPhoto: coverPhoto, discPhoto: discPhoto, genres: genres)
                    } else if let discPhoto = discPhoto {
                        print("Adding disc")
                        self.addNewRecord(id: snap.key, name: name as! String, artist: artist as! String, releaseYear: releaseYear as! Int, discPhoto: discPhoto, genres: genres)
                    } else if let coverPhoto = coverPhoto {
                        print("Adding cover")
                        self.addNewRecord(id: snap.key, name: name as! String, artist: artist as! String, releaseYear: releaseYear as! Int, coverPhoto: coverPhoto, genres: genres)
                    } else {
                        print("No Photo")
                        self.addNewRecord(id: snap.key, name: name as! String, artist: artist as! String, releaseYear: releaseYear as! Int, genres: genres)
                    }
                    completion()
                }
            }
        })
    }

    
    private func sortRecords() {
        // Sorting of local library
        switch sortingFactor {
//        case .dateAdded:
//            vinylRecords.sort { $0.dateAdded > $1.dateAdded }
        case .artist:
            recordLibrary.sort {
                if $0.artist != $1.artist {
                    return $0.artist < $1.artist
                } else {
                    return $0.name < $1.name
                }
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
        self.pullSortingHeaders()
    }
    
    private func pullSortingHeaders(){
        for record in self.recordLibrary{
            if let character = record.artist.first, !sortingElementHeaders.artist.contains(String(character)) {
                sortingElementHeaders.artist.append(String(character))
            }
            if let character = record.name.first, !sortingElementHeaders.album.contains(String(character)) {
                sortingElementHeaders.album.append(String(character))
            }
            if !sortingElementHeaders.releaseYear.contains(String(record.releaseYear)){
                sortingElementHeaders.releaseYear.append(String(record.releaseYear))
            }
        }
        sortingElementHeaders.artist = sortingElementHeaders.artist.sorted(by: {$0 < $1})
        sortingElementHeaders.album = sortingElementHeaders.album.sorted(by: {$0 < $1})
        sortingElementHeaders.releaseYear = sortingElementHeaders.releaseYear.sorted(by: {$0 < $1})
    }
    
    func fetchPhotoByID(id: String) -> UIImage? {
        if let recordItem = recordDictionaryByID[id] {
            return recordItem.coverPhoto
        }
        print("Couldn't find id in dictionary")
        return UIImage(named:"TakePhoto")  // Return defaultIm if the ID is not found
    }
    
    func refreshData(){
        print("REFRESHING DATA")
        recordLibrary = []
        recordDictionaryByID = [:]
        fetchData{
            self.sortRecords()
        }
    }
    
    
    
}
