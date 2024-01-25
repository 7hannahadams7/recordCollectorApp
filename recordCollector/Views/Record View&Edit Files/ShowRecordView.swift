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
    @State private var recordName = ""
    @State private var artistName = ""
    var record: RecordItem
    @State private var releaseYear: Int = 2024
    
    @State private var editingMode: Bool = false
    @State private var newPhoto: Bool = false
    
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
                Image("Page-Background-2").resizable().ignoresSafeArea().aspectRatio(contentMode: .fill)
                VStack{
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
                                        Image(systemName:"return").foregroundColor(decorBlack)
                                    }
                                }
                                Spacer()
                            }
                        }.frame(height:150)
                        RecordImageDisplayView(viewModel: viewModel, record: record, newPhoto: $newPhoto, editingMode: $editingMode)
                        VStack{
                            if editingMode{
                                Button(action:{
                                    viewModel.editRecordEntry(id: id, recordName: recordName, artistName: artistName, releaseYear: releaseYear, newPhoto: newPhoto, genres: genreManager.genres)
                                    viewModel.resetPhoto()
//                                    editingMode.toggle()
                                    presentationModeShowRecord.wrappedValue.dismiss() // Dismiss the View after update
                                }){
                                    ZStack{
                                        Circle().fill(seaweedGreen).frame(width:60,height:60).padding(.horizontal)
                                        Image(systemName:"checkmark").foregroundColor(decorWhite)
                                    }
                                }
                                Spacer()
                            }
                        }.frame(height:150)
                    }.padding(.top,editingMode ? 65 : 50)
                    RecordFieldDisplayView(viewModel: viewModel, genreManager: genreManager, record: record, editingMode: $editingMode, recordName: $recordName, artistName: $artistName, releaseYear: $releaseYear, showAlert: $showAlert)
                    
                    if editingMode{
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
                    }else{
                        Button(action:{
                            editingMode.toggle()
                        }) {
                            
                            Text("Edit Record").foregroundStyle(iconWhite)
                            
                        }.padding(20).background(pinkRed).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20)
                    }
                    
                    Spacer()
                    
                }
                
            }.onAppear {
                //Initial set of genres list
                genreManager.genres = record.genres
            }.onDisappear{
                viewModel.refreshData()
            }
        }.navigationBarBackButtonHidden(editingMode)
        
    }
    
    
}


