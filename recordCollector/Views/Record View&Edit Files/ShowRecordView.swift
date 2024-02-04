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
    @ObservedObject private var keyboard = KeyboardResponder()
    
    var record: RecordItem
    
    @State private var recordName = ""
    @State private var artistName = ""
    @State private var releaseYear: Int = 2024
    @State private var dateAdded = Date()
    @State private var isBand: Bool = false
    
    @State private var editingMode: Bool = false
    @State private var newPhoto: Bool = false
    @State private var listeningMode: Bool = false
    
    @State private var showAlert: Bool = false
    var isFormValid: Bool {
        return !recordName.isEmpty && !artistName.isEmpty
    }
    
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
                            ZStack{
                                HStack{
                                    VStack{
                                        if editingMode{
                                            Button(action:{
                                                viewModel.resetPhoto()
                                                editingMode.toggle()
                                                genreManager.genres = record.genres
                                            }){
                                                ZStack{
                                                    Circle().fill(decorWhite).frame(width:60,height:60).padding(.horizontal)
                                                    Image(systemName:"xmark").foregroundColor(decorBlack)
                                                }
                                            }
                                        }
                                    }
                                    Spacer()
                                    VStack{
                                        if editingMode{
                                            Button(action:{
                                                viewModel.editRecordEntry(id: id, recordName: recordName, artistName: artistName, releaseYear: releaseYear, newPhoto: newPhoto, genres: genreManager.genres, dateAdded: dateToString(date: dateAdded),isBand:isBand)
                                                viewModel.resetPhoto()
                                                editingMode.toggle()
                                            }){
                                                ZStack{
                                                    Circle().fill(seaweedGreen).frame(width:60,height:60).padding(.horizontal)
                                                    Image(systemName:"checkmark").foregroundColor(decorWhite)
                                                }
                                            }
                                        }
                                    }
                                    
                                }.frame(height:150)
                                RecordImageDisplayView(viewModel: viewModel, record: record, newPhoto: $newPhoto, editingMode: $editingMode)
                            }
                            if listeningMode{
                                ListenNow(viewModel:viewModel,spotifyController:spotifyController,record:record).frame(height:screenHeight/3 + 100)
                            }else{
                                RecordFieldDisplayView(viewModel: viewModel, genreManager: genreManager, record: record, editingMode: $editingMode, recordName: $recordName, artistName: $artistName, releaseYear: $releaseYear, dateAdded: $dateAdded, isBand: $isBand, showAlert: $showAlert)
                            }
                            
                            // BOTTOM BUTTONS
                            if editingMode{
                                // DELETE RECORD BUTTON
                                Button(action:{
                                    Task{
                                        await viewModel.deleteRecordEntry(id: id)
                                    }
                                    
                                    presentationModeShowRecord.wrappedValue.dismiss() // Dismiss the View after update
                                }) {
                                    HStack{
                                        Text("DELETE RECORD").foregroundStyle(iconWhite)
                                        Image(systemName:"xmark").foregroundColor(iconWhite)
                                    }
                                    
                                }.padding(20).frame(width:3*screenWidth/4).background(pinkRed).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20)
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
                                        
                                        Text("Edit Record").foregroundStyle(iconWhite)
                                        
                                    }.padding(20).background(pinkRed).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20)
                                    Button(action:{
                                        listeningMode.toggle()
                                    }){
                                        VStack{
                                            Image("playButton").resizable().frame(width:50,height:50)
                                            Text("Play Now")
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                            
                        }.padding(.vertical)
                    }
                }.onAppear {
                    //Initial set of genres list
                    genreManager.genres = record.genres
                }
            /*.padding(.bottom, keyboard.currentHeight/2)*/ // Move frame up to type in genre box
        }
            
    }
    
    
}


