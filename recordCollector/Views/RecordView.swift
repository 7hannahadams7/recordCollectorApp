//
//  AddRecordView.swift
//  test3
//
//  Created by Hannah Adams on 1/8/24.
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
    
    @ObservedObject var genreManager: GenreManager
    
    @State private var newGenre = ""
    
    @Environment(\.presentationMode) var presentationModeShowRecord
    
    var body: some View {
        let id = record.id
        
            ZStack(alignment:.center) {
                Image("Page-Background-2").resizable().ignoresSafeArea().aspectRatio(contentMode: .fill)
                VStack{

                    RecordImageDisplayView(viewModel: viewModel, record: record, newPhoto: $newPhoto, editingMode: $editingMode)
                    
                    RecordFieldDisplayView(viewModel: viewModel, genreManager: genreManager, record: record, editingMode: $editingMode, recordName: $recordName, artistName: $artistName, releaseYear: $releaseYear)
                    
                    if editingMode{
                        HStack{
                            Button(action:{
                                viewModel.resetPhoto()
                                editingMode.toggle()
                                genreManager.genres = record.genres
                            }) {
                                
                                Text("Cancel").foregroundStyle(iconWhite)
                                
                            }.padding(20).background(pinkRed).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20)
                            
                            Button(action:{
                                viewModel.editRecordEntry(id: id, recordName: recordName, artistName: artistName, releaseYear: releaseYear, newPhoto: newPhoto, genres: genreManager.genres)
                                viewModel.resetPhoto()
                                
                                presentationModeShowRecord.wrappedValue.dismiss() // Dismiss the View after update
                            }) {
                                
                                Text("Save Changes").foregroundStyle(iconWhite)
                                
                            }.padding(20).background(seaweedGreen).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20)
                            
                            
                        }
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

        
    }
    
    
}


struct RecordImageDisplayView: View{
    @ObservedObject var viewModel: LibraryViewModel
    var record: RecordItem?
    
    @State private var isImagePickerPresented: Bool = false
    @Binding var newPhoto: Bool
    
    @Binding var editingMode: Bool
    
    var body: some View{
        ZStack{
            Button(action:{
                viewModel.capturePhoto()
                newPhoto = true
            }) {
                // Show the photo capture screen
                ZStack{
                    RoundedRectangle(cornerRadius:10).fill(iconWhite).aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                    if let capturedImage = viewModel.capturedImage {
                        // If photo captured, show
                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width:200,height: 200).padding(.all,10).clipped()
                    }else if record != nil{
                        Image(uiImage: record!.photo).resizable()
                                .scaledToFill()
                                .frame(width:200,height: 200).clipped().padding(.all,10)
                    } else{
                        Image("TakePhoto")
                            .resizable()
                            .scaledToFill()
                            .frame(width:200,height: 200).clipped().padding(.all,10)
                    }
                }.frame(width:200,height: 200)
                
                
            }.disabled(!editingMode)
                .sheet(isPresented: $viewModel.isImagePickerPresented) {
                    ImagePicker(isPresented: $viewModel.isImagePickerPresented, imageCallback: viewModel.imagePickerCallback)
                }
                .onTapGesture {
                    print("Tapped Button")
                    print("Button Enabled? ", editingMode)
                }
            
        }.padding(.top,50)
    }
}

struct RecordFieldDisplayView: View{
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var genreManager: GenreManager
    
    var record: RecordItem?
    
    @Binding var editingMode: Bool
    
    @Binding var recordName: String
    @Binding var artistName: String
    @Binding var releaseYear: Int
    
    @State private var newGenre = ""
    
    var body: some View{
        
        VStack{
            // Name Field
            HStack{
                HStack{
                    Text("Name: ")
                    Spacer()
                }.frame(width:screenWidth/4)
                if editingMode{
                    TextField("Name", text: $recordName).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2)
                        .onAppear {
                            if record != nil{
                                recordName = record!.name
                            }
                        }
                }else{
                    Text(record?.name ?? "").padding().frame(width:screenWidth/2, alignment:.leading).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
            }
            
            // Artist Field
            HStack{
                HStack{
                    Text("Artist: ")
                    Spacer()
                }.frame(width:screenWidth/4)
                if editingMode{
                    TextField("Artist", text: $artistName).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2).aspectRatio(contentMode: .fill)
                        .onAppear {
                            if record != nil{
                                artistName = record!.artist
                            }
                        }
                }else{
                    Text(record?.artist ?? "").padding().frame(width:screenWidth/2, alignment:.leading).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
            }
            
            // Release Year Field
            HStack{
                HStack{
                    Text("Release Year: ")
                    Spacer()
                }.frame(width:screenWidth/4)
                if editingMode{
                    Picker("Year", selection: $releaseYear) {
                        ForEach((1500..<Int(Date.now.formatted(.dateTime.year()))!+1).reversed(), id:\.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }.onAppear {
                        if record != nil{
                            releaseYear = record!.releaseYear
                        }
                    }
                    .padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2,alignment:.leading)
                }else{
                    Text(String(record?.releaseYear ?? 2024)).padding().frame(width:screenWidth/2, alignment:.leading).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
            }
            
            //Genre Field
            HStack{
                HStack{
                    Text("Genres: ")
                    Spacer()
                }.frame(width:screenWidth/4)
                    VStack(alignment:.leading){
                        if editingMode{
                            HStack{
                                TextField("Genre", text: $newGenre).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Button(action: {
                                    if newGenre != ""{
                                        genreManager.addGenre(newGenre)
                                        newGenre = ""
                                    }
                                }) {
                                    Image(systemName: "plus").foregroundColor(recordBlack).padding()
                                }
                            }
                        }
                        ScrollView(.horizontal) {
                            HStack{
                                ForEach(genreManager.genres.reversed(), id: \.self){genre in
                                    Button(action: {
                                        genreManager.removeGenre(genre)
                                    }, label: {
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 5).foregroundColor(iconWhite)
                                            HStack{
                                                Text(genre).font(.system(size:15))
                                                if editingMode{
                                                    Image(systemName: "xmark")
                                                }
                                            }.padding(.horizontal)
                                        }
                                    }).disabled(!editingMode)
                                }
                            }.frame(height:30)
                        }
                    }.padding().background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2,alignment:.leading)
                Spacer()
            }
            
            
        }.padding(.all, 20).background(lightWoodBrown).clipShape(RoundedRectangle(cornerRadius: 10)).padding(20)
        
    }
    
}

class GenreManager: ObservableObject {
    @Published var genres: [String] = []
    
    init(){
        print("CREATED NEW GENREMANAGER")
    }
    
    func addGenre(_ genre: String) {
        genres.append(genre)
    }

    func removeGenre(_ genre: String) {
        genres.removeAll { $0 == genre }
    }
}




