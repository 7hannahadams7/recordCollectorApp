//
//  ShowRecordView.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/25/24.
//

import SwiftUI
import FirebaseDatabase
import FirebaseStorage

struct ShowRecordView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    
    var record: RecordItem
    
    @State private var recordName = ""
    @State private var artistName = ""
    @State private var releaseYear: Int = 2024
    @State private var dateAdded = Date()
    @State private var isBand: Bool = false
    @State private var isUsed: Bool = false
    @State private var storeName = ""
    @State private var location = ""
    
    @State private var editingMode: Bool = false
    
    @State private var newCoverPhoto: Bool = false
    @State private var newDiskPhoto: Bool = false
    
    @State private var listeningMode: Bool = false
    
    @State private var showAlert: Bool = false
    var isFormValid: Bool {
        return !recordName.isEmpty && !artistName.isEmpty
    }
    
    @State private var confirmDeletePopup:Bool = false
    
    @ObservedObject var genreManager: GenreManager
    
    @State private var newGenre = ""
    
    @Environment(\.presentationMode) var presentationModeShowRecord
    
    var body: some View {
        let id = record.id
        NavigationView{
                ZStack(alignment:.center) {
                    Color(woodBrown).edgesIgnoringSafeArea(.all)
                    ScrollView{
                        VStack{
                            RecordImageDisplayView(viewModel: viewModel, record: record, newCoverPhoto: $newCoverPhoto, newDiskPhoto: $newDiskPhoto, editingMode: $editingMode)
                            
                            if listeningMode{
                                ListenNowView(viewModel:viewModel,spotifyController:spotifyController,record:record).frame(height:screenHeight/3 + 100)
                            }else{
                                RecordFieldDisplayView(viewModel: viewModel, genreManager: genreManager, record: record, editingMode: $editingMode, recordName: $recordName, artistName: $artistName, releaseYear: $releaseYear, dateAdded: $dateAdded,isBand:$isBand,isUsed:$isUsed,storeName:$storeName,location:$location,showAlert: $showAlert, listeningMode: $listeningMode)
                            }
                            
                            // BOTTOM BUTTONS
                            if editingMode{
                                // DELETE RECORD BUTTON
                                HStack{

                                    // Exit Edit Mode Button
                                    Button(action:{
                                        viewModel.resetPhoto()
                                        editingMode.toggle()
                                        genreManager.genres = record.genres
                                    }){
                                        ZStack{
                                            Circle().fill(decorWhite)
                                            Image(systemName:"xmark").resizable().padding().foregroundColor(decorBlack).aspectRatio(contentMode:.fill)
                                        }.frame(width:60,height:60).padding(.horizontal)
                                    }
                                    
                                    // Delete Record Button
                                    Button(action: {
                                        // Show the confirmation alert
                                        confirmDeletePopup.toggle()
                                    }) {
                                        ZStack{
                                            Circle().fill(pinkRed)
                                            Image(systemName: "trash").resizable().padding().foregroundColor(decorWhite).aspectRatio(contentMode: .fill)
                                        }.frame(width:60, height:60).padding(.horizontal)
                                    }
                                    .popover(isPresented: $confirmDeletePopup, arrowEdge: .bottom) {
                                        // Confirm Delete Popup
                                        VStack {
                                            VStack{
                                                Text("Confirm Delete")
                                                    .smallHeadlineText().padding()
                                                
                                                Text("Are you sure you want to delete this record? This action cannot be undone.").mainText()
                                                    .multilineTextAlignment(.center).padding()
                                                
                                                HStack {
                                                    // Cancel button
                                                    Button{
                                                        confirmDeletePopup.toggle()
                                                    }label:{
                                                        Text("Cancel").smallHeadlineText()
                                                    }
                                                    .padding()
                                                    .foregroundColor(.blue)
                                                    
                                                    Spacer()
                                                    // Delete button
                                                    Button{
                                                        // Delete the record and dismiss the view
                                                        Task {
                                                            await viewModel.deleteRecordEntry(id: id)
                                                        }
                                                        
                                                        presentationModeShowRecord.wrappedValue.dismiss()
                                                        
                                                        // Close the confirmation alert
                                                        confirmDeletePopup.toggle()
                                                    } label:{
                                                        Text("Delete").smallHeadlineText()
                                                    }
                                                    .padding()
                                                    .foregroundColor(.red)
                                                }
                                            }.padding().frame(width:3*screenWidth/4).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 25.0))
                                        }
                                        .padding().clearModalBackground()
                                    }


                                    // Save Changes Button
                                    Button(action:{
                                        viewModel.editRecordEntry(id: id, recordName: recordName, artistName: artistName, releaseYear: releaseYear, newCoverPhoto: newCoverPhoto, newDiskPhoto: newDiskPhoto, genres: genreManager.genres, dateAdded: Date.dateToString(date: dateAdded),isBand:isBand,isUsed:isUsed,storeName:storeName)
                                        if viewModel.storeViewModel.allStores[storeName] == nil{
                                            viewModel.storeViewModel.addNewStore(storeName: storeName, address: location,id:id)
                                        }
                                        viewModel.resetPhoto()
                                        editingMode.toggle()
                                    }){
                                        ZStack{
                                            Circle().fill(seaweedGreen)
                                            Image(systemName:"checkmark").resizable().padding().foregroundColor(decorWhite).aspectRatio(contentMode:.fill)
                                        }.frame(width:60,height:60).padding(.horizontal)
                                    }

                                    
                                }.padding(20)

                            }else if listeningMode{
                                // DISPLAYING SPOTIFY OPTIONS
                                Button(action:{
                                    listeningMode.toggle()
                                }){
                                    Text("Back to Record")
                                }
                            }else {
                                // EDITING AND PLAYING OPTION
                                HStack{
                                    Button(action:{
                                        editingMode.toggle()
                                    }) {
                                        
                                        HStack{
                                            Text("Edit Record").foregroundStyle(decorBlack)
                                            Image(systemName: "square.and.pencil").resizable().aspectRatio(contentMode: .fit).frame(width:20, height:20).foregroundStyle(decorBlack)
                                        }
                                        
                                    }.padding(20).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10))
                                }.frame(height:50).padding()
                            }
                            
                            Spacer()
                            
                        }.padding(.vertical)
                    }
                }.onAppear {
                    //Initial set of genres list
                    genreManager.genres = record.genres
                }
        }
            
    }
    
    
}


