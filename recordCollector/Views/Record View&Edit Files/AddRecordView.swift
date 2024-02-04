//
//  AddRecordView.swift
//  test3
//
//  Created by Hannah Adams on 1/8/24.
//

import SwiftUI
import FirebaseDatabase
import FirebaseStorage

struct AddRecordView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject private var keyboard = KeyboardResponder()
    
    @State private var recordName = ""
    @State private var artistName = ""
    @State private var releaseYear: Int = 2024
    @State private var dateAdded = Date()
    @State private var isBand: Bool = false
    
    
    @State private var isImagePickerPresented: Bool = false
    @Environment(\.presentationMode) var presentationModeAddItem
    
    @State private var editingMode: Bool = true
    @State private var newPhoto: Bool = false
    
    @State private var showAlert: Bool = false
    var isFormValid: Bool {
        return !recordName.isEmpty && !artistName.isEmpty
    }
    
    @ObservedObject var genreManager: GenreManager
    
    @State private var newGenre = ""
    
    
    var ref: DatabaseReference! = Database.database().reference()
    
    var body: some View {
        NavigationView{
            ZStack(alignment:.center) {
                Color(woodBrown).edgesIgnoringSafeArea(.all)
                
                ScrollView{
                    VStack{
                        RecordImageDisplayView(viewModel: viewModel,newPhoto: $newPhoto, editingMode: $editingMode)
                        
                        RecordFieldDisplayView(viewModel: viewModel, genreManager: genreManager, editingMode: $editingMode, recordName: $recordName, artistName: $artistName, releaseYear: $releaseYear, dateAdded: $dateAdded,
                                               isBand:$isBand,            showAlert: $showAlert)
                        
                        Button(action:{
                            if isFormValid{
                                viewModel.uploadRecord(recordName: recordName, artistName: artistName, releaseYear: releaseYear, genres: genreManager.genres,dateAdded:formattedDate, isBand:isBand)
                                
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
            }.padding(.bottom, keyboard.currentHeight/2)
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

