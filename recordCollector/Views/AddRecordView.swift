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
    @State private var recordName = ""
    @State private var artistName = ""
    @State private var releaseYear: Int = 2024
    @State private var isImagePickerPresented: Bool = false
    @Environment(\.presentationMode) var presentationModeAddItem
    
    @State private var editingMode: Bool = true
    @State private var newPhoto: Bool = false
    
    @ObservedObject var genreManager = GenreManager()
    @State private var newGenre = ""
    
    var ref: DatabaseReference! = Database.database().reference()
    
    var body: some View {
        
        ZStack(alignment:.center) {
            Image("Page-Background-2").resizable().ignoresSafeArea().aspectRatio(contentMode: .fill)
            VStack{
                RecordImageDisplayView(viewModel: viewModel,newPhoto: $newPhoto, editingMode: $editingMode)
                
                RecordFieldDisplayView(viewModel: viewModel, genreManager: genreManager, editingMode: $editingMode, recordName: $recordName, artistName: $artistName, releaseYear: $releaseYear)
                
                Button(action:{
                    viewModel.uploadRecord(recordName: recordName, artistName: artistName, releaseYear: releaseYear, genres: genreManager.genres)

                    presentationModeAddItem.wrappedValue.dismiss() // Dismiss the AddItemView
                }) {
                    
                    Text("Add Record").foregroundStyle(iconWhite)

                }.padding(20).background(pinkRed).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20)
                
                Spacer()
                            
            }
            
        }.onDisappear(){
            viewModel.resetPhoto()
            viewModel.refreshData()
        }
        .onAppear {
            UITableView.appearance().backgroundView = UIImageView(image: UIImage(named: "Page-Background"))
        }
        
    }
    
    
}


struct AddRecordViewPageView_Previews: PreviewProvider {
    static var previews: some View {
        AddRecordView(viewModel:LibraryViewModel())
    }
}

