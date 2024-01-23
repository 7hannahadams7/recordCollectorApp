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
    
    @Published var isImagePickerPresented: Bool = false
    @Published var capturedImage: UIImage? = nil
    
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
//    
//    init() {
//        fetchData {
//            self.sortRecords()
//        }
//    }
    
    // MARK: - Photo Actions
    func resetPhoto(){
        print("Resetting Captured Photo")
        capturedImage = nil
    }
    
    func capturePhoto() {
        print("capturePhoto selected")
        isImagePickerPresented = true
    }

    func imagePickerCallback(image: UIImage?) {
        capturedImage = image
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

        uploadPhoto(id: id, image: self.capturedImage)
        
        print("Added New Record, ID #: ", id)
        
    }
    
    func addNewRecord(id: String, name: String, artist: String, releaseYear: Int, photo: UIImage? = UIImage(named:"TakePhoto"),genres:[String]) {
        let newItem = RecordItem(id: id, name: name, artist: artist, photo:photo!, releaseYear: releaseYear,genres:genres)
        recordLibrary.append(newItem)
        recordDictionaryByID[id] = newItem
    }
    
    func uploadPhoto(id: String, image: UIImage?) -> Void{
        print("Attempting Image Upload")
        let ref: DatabaseReference! = Database.database().reference()
        // Check selected image property not nil
        guard image != nil else{
            print("404 - ERROR No Image Uploaded, ID #: ", id)
            return
        }
        
        // Create storage reference
        let storageRef = Storage.storage().reference()
        
        // Turn image into jpeg data
        let imageData = image!.jpegData(compressionQuality: 0.5)
        
        // Check that we were able to convert it to data
        guard imageData != nil else{
            print("404 - ERROR Cannot Convert Image, ID #: ", id)
            return
        }
        
        // Specify the file path and name
        let path = "recordImages/" + id + ".jpg"
        let fileRef = storageRef.child(path)
        
        // Upload data
        _ = fileRef.putData(imageData!, metadata:nil){
            metadata, error in
            
            // Check no errors
            if error == nil && metadata != nil{
                // Add upload status/URL to DB entry
                ref.child("Records").child(id).child("imageURL").setValue(path)
                print("Image Upload Successful, ID #: ", id)
                
            }else{
                print("404 - ERROR Image Upload, ID #: ", id)
                return
            }
        }
        
        
    }
    
    func editRecordEntry(id: String,recordName: String? = nil, artistName: String? = nil, releaseYear: Int? = nil, newPhoto: Bool, genres: [String]? = nil){
        print("Editing Entry: ", id, "NEW PHOTO? ", newPhoto)
        let ref: DatabaseReference! = Database.database().reference()
        
        var recordItem = recordDictionaryByID[id]!
        
        // Re-value child elements
        if artistName != nil{
//            recordItem.artist = artistName!
            ref.child("Records").child(id).child("artist").setValue(String(artistName!))
        }
        if artistName != nil{
//            recordItem.name = recordName!
            ref.child("Records").child(id).child("name").setValue(String(recordName!))
        }
        if releaseYear != nil{
//            recordItem.releaseYear = releaseYear!
            ref.child("Records").child(id).child("releaseYear").setValue(releaseYear!)
        }
        
        // Attempt to upload photo if new photo available, uploadPhoto adds the photo to the database if possible
        if newPhoto{
            uploadPhoto(id: id, image: self.capturedImage)
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
        
//        sortRecords()
        
        print("Updated Record, ID #: ", id)
    }
    
    
    // MARK: - Library Data Initializing (Fetching, Sorting, etc.)
    private func fetchData(completion: @escaping () -> Void){
        let allRecords = Database.database().reference().child("Records")
        let storageRef = Storage.storage().reference()
//        print("View Model Completing Fetch...")

        allRecords.observeSingleEvent(of: .value, with: { snapshot in
            let dispatchGroup = DispatchGroup()
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let elementDict = snap.value as! [String: Any]
                
                let artist = elementDict["artist"]
                let name = elementDict["name"]
                let releaseYear = elementDict["releaseYear"]
                
                var genres: [String] = []
                // Check if "genres" key exists in the dictionary
                if let genresDict = elementDict["genres"] as? [String: Bool] {
                    // Iterate through the keys of the genres dictionary
                    for (genre, value) in genresDict {
                        // Check if the value is true
                        if value {
                            genres.append(genre)
                        }
                    }
                }
                
                
                if let im = elementDict["imageURL"]{
                    let fileRef = storageRef.child(im as! String)
                    fileRef.getData(maxSize: 1 * 1024 * 1024, completion: { data, error in
                        if error == nil && data != nil{
                            let image = UIImage(data: data!)
                            print("Storing with image")
                            DispatchQueue.main.async{
                                self.addNewRecord(id: snap.key, name: name as! String, artist: artist as! String, releaseYear: releaseYear as! Int, photo: image!, genres:genres)
                            }
                        }else{
                            print("Error on image fetch - storing without image")
                            DispatchQueue.main.async{
                                self.addNewRecord(id: snap.key, name: name as! String, artist: artist as! String, releaseYear: releaseYear as! Int,genres:genres)
                                print("Fetch Complete - 2")
                            }
                        }
                        dispatchGroup.leave()
                    })
                }else{
                    print("Storing without image (No image available)")
                    DispatchQueue.main.async{
                        self.addNewRecord(id: snap.key, name: name as! String, artist: artist as! String, releaseYear: releaseYear as! Int,genres:genres)
                        dispatchGroup.leave()
                    }
                    
                }
                dispatchGroup.enter()
            }
            dispatchGroup.notify(queue: .main) {
                 // Call the completion block once all data is processed
                 completion()
             }
        })
        
    }
    
    private func sortRecords() {
        switch sortingFactor {
//        case .dateAdded:
//            vinylRecords.sort { $0.dateAdded > $1.dateAdded }
        case .artist:
            print("INITIAL SORT")
            recordLibrary.sort { $0.artist < $1.artist }
        case .releaseYear:
            recordLibrary.sort { $0.releaseYear < $1.releaseYear }
        case .album:
            recordLibrary.sort { $0.name < $1.name }
        }
    }
    
    func fetchPhotoByID(id: String) -> UIImage? {
        if let recordItem = recordDictionaryByID[id] {
            return recordItem.photo
        }
        return UIImage(named:"MenuUp")  // Return defaultIm if the ID is not found
    }
    
    func refreshData(){
        recordLibrary = []
        recordDictionaryByID = [:]
        fetchData{
            self.sortRecords()
        }
    }
    
//    private func setupDatabaseListener() {
//        let ref = Database.database().reference().child("Records")
//
//        // Set up an observer for the "Records" node
//        ref.observe(.value) { [weak self] snapshot in
//            guard let self = self else { return }
//
//            // Handle the change in data
//            let elementDict = snapshot.value as! [String: Any]
//
//            let artist = elementDict["artist"] as! String
//            let name = elementDict["name"] as! String
//            let releaseYear = elementDict["releaseYear"] as! Int
//
//            var genres: [String] = []
//
//            // Check if "genres" key exists in the dictionary
//            if let genresDict = elementDict["genres"] as? [String: Bool] {
//                // Iterate through the keys of the genres dictionary
//                for (genre, value) in genresDict {
//                    // Check if the value is true
//                    if value {
//                        genres.append(genre)
//                    }
//                }
//            }
//
////            if let im = elementDict["imageURL"] {
////                let storageRef = Storage.storage().reference().child(im as! String)
////                storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
////                    if error == nil, let data = data, let image = UIImage(data: data) {
////                        DispatchQueue.main.async {
////                            // Find the corresponding record in recordItems and update it
////                            if let index = self.recordLibrary.firstIndex(where: { $0.id == snap.key }) {
////                                self.recordLibrary[index] = RecordItem(id: snap.key, name: name, artist: artist, releaseYear: releaseYear, photo: image, genres: genres)
////                            }
////                        }
////                    }
////                }
////            } else {
////                DispatchQueue.main.async {
////                    // Find the corresponding record in recordItems and update it
////                    if let index = self.recordItems.firstIndex(where: { $0.id == snap.key }) {
////                        self.recordItems[index] = RecordItem(id: snap.key, name: name, artist: artist, releaseYear: releaseYear, genres: genres)
////                    }
////                }
////            }
//        }
//    }
//
//    // Call this method to set up the database listener (e.g., in your ViewModel's initializer)
//    func startListening() {
//        setupDatabaseListener()
//    }
    
    
}
