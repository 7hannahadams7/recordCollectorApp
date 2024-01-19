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
    
    init() {
        fetchData {
            self.sortRecords()
        }
    }
    
    // Photo Taking Functions
    func resetPhoto(){
        print("Resetting")
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
    
    
    func addNewRecord(id: String, name: String, artist: String, releaseYear: Int, photo: UIImage? = UIImage(named:"MenuUp")) {
        let newItem = RecordItem(id: id, name: name, artist: artist, photo:photo, releaseYear: releaseYear)
        recordLibrary.append(newItem)
        recordDictionaryByID[id] = newItem
    }
    
    func uploadPhoto(id: String, image: UIImage?) -> Void{
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
    
    func uploadRecord(recordName: String, artistName: String, releaseYear: Int){
        // UUID of entry
        let id = UUID().uuidString
        
        let ref: DatabaseReference! = Database.database().reference()
        
        // Add child elements
        ref.child("Records").child(id).child("artist").setValue(String(artistName))
        ref.child("Records").child(id).child("name").setValue(String(recordName))
        ref.child("Records").child(id).child("releaseYear").setValue(releaseYear)
        
        

        // Attempt to upload photo, uploadPhoto adds the photo to the database if possible
        uploadPhoto(id: id, image: self.capturedImage)
        
        print("Added New Record, ID #: ", id)
        
    }
    
    func editRecordEntry(id: String,recordName: String, artistName: String, releaseYear: Int, newPhoto: Bool){
        let ref: DatabaseReference! = Database.database().reference()
        
        // Re-value child elements
        ref.child("Records").child(id).child("artist").setValue(String(artistName))
        ref.child("Records").child(id).child("name").setValue(String(recordName))
        ref.child("Records").child(id).child("releaseYear").setValue(releaseYear)
        
        // Attempt to upload photo if new photo available, uploadPhoto adds the photo to the database if possible
        if newPhoto{
            uploadPhoto(id: id, image: self.capturedImage)
        }
        
        print("Updated Record, ID #: ", id)
    }
    
    private func fetchData(completion: @escaping () -> Void){
        let allRecords = Database.database().reference().child("Records")
        let storageRef = Storage.storage().reference()
//        print("View Model Completing Fetch...")

        allRecords.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let elementDict = snap.value as! [String: Any]
                
                if let im = elementDict["imageURL"]{
                    let fileRef = storageRef.child(im as! String)
                    fileRef.getData(maxSize: 1 * 1024 * 1024, completion: { data, error in
                        if error == nil && data != nil{
                            let image = UIImage(data: data!)
                            print("Storing with image")
                            DispatchQueue.main.async{
                                self.addNewRecord(id: snap.key, name: elementDict["name"] as! String, artist: elementDict["artist"] as! String, releaseYear: elementDict["releaseYear"] as! Int, photo: image!)
                            }
                        }else{
                            print("Error on image fetch - storing without image")
                            DispatchQueue.main.async{
                                self.addNewRecord(id: snap.key, name: elementDict["name"] as! String, artist: elementDict["artist"] as! String, releaseYear: elementDict["releaseYear"] as! Int)
                                print("Fetch Complete - 2")
                            }
                        }
                    })
                }else{
                    print("Storing without image (No image available")
                    DispatchQueue.main.async{
                        self.addNewRecord(id: snap.key, name: elementDict["name"] as! String, artist: elementDict["artist"] as! String, releaseYear: elementDict["releaseYear"] as! Int)
                    }
                }
            }
        })
        
    }
    
    private func sortRecords() {
        switch sortingFactor {
//        case .dateAdded:
//            vinylRecords.sort { $0.dateAdded > $1.dateAdded }
        case .artist:
            recordLibrary.sort { $0.artist < $1.artist }
        case .releaseYear:
            recordLibrary.sort { $0.releaseYear < $1.releaseYear }
        case .album:
            recordLibrary.sort { $0.name < $1.name }
        }
    }
    
    
}
