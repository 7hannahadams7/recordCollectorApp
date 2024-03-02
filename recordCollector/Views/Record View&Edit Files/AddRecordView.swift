//
//  AddRecordView.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/8/24.
//

import SwiftUI

struct AddRecordView: View {
    @ObservedObject var viewModel: LibraryViewModel

    @State private var recordName = ""
    @State private var artistName = ""
    @State private var releaseYear: Int = 2024
    @State private var dateAdded = Date()
    @State private var isBand: Bool = false
    @State private var isUsed: Bool = false
    @State private var storeName = ""
    @State private var location = ""
    
    @State private var listeningMode: Bool = true
    
    @State private var isImagePickerPresented: Bool = false
    @Environment(\.presentationMode) var presentationModeAddItem
    
    @State private var editingMode: Bool = true
    @State private var newCoverPhoto: Bool = false
    @State private var newDiskPhoto: Bool = false
    
    @State private var showAlert: Bool = false
    var isFormValid: Bool {
        return !recordName.isEmpty && !artistName.isEmpty
    }
    
    @ObservedObject var genreManager: GenreManager
    
    @State private var newGenre = ""
    
    var body: some View {
        NavigationView{
            ZStack(alignment:.center) {
                Color(woodBrown).edgesIgnoringSafeArea(.all)
                
                ScrollView{
                    VStack{
                        RecordImageDisplayView(viewModel: viewModel,newCoverPhoto: $newCoverPhoto,newDiskPhoto:$newDiskPhoto, editingMode: $editingMode)
                        
                        RecordFieldDisplayView(viewModel: viewModel, genreManager: genreManager, editingMode: $editingMode, recordName: $recordName, artistName: $artistName, releaseYear: $releaseYear, dateAdded: $dateAdded,isBand:$isBand,isUsed:$isUsed,storeName:$storeName,location:$location   ,showAlert: $showAlert, listeningMode: $listeningMode)
                        
                        Button(action:{
                            if isFormValid{
                                viewModel.storeViewModel.addNewStore(storeName: storeName, address: location, completion:{
                                    viewModel.uploadRecord(recordName: recordName, artistName: artistName, releaseYear: releaseYear, genres: genreManager.genres,dateAdded:formattedDate, isBand:isBand,isUsed:isUsed,storeName:storeName)
                                })

                                presentationModeAddItem.wrappedValue.dismiss() // Dismiss the AddItemView
                            }else{
                                showAlert = true
                            }
                        }) {
                            
                            Text("Add Record").foregroundStyle(iconWhite)
                            
                        }                .padding(20).background(pinkRed).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20)
                        
                        Spacer()
                        
                    }.padding(.vertical)
                }
            }.onDisappear(){
                viewModel.resetPhoto()
            }
            .onAppear {
                genreManager.genres = []
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: dateAdded)
    }
    
    
}


struct AddRecordViewPageView_Previews: PreviewProvider {
    static var previews: some View {
        AddRecordView(viewModel:LibraryViewModel(),genreManager:GenreManager())
    }
}

