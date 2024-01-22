//
//  AddRecordView.swift
//  test3
//
//  Created by Hannah Adams on 1/8/24.
//

import SwiftUI
import FirebaseDatabase
import FirebaseStorage

//struct ShowRecordView2: View {
//    @ObservedObject var viewModel: LibraryViewModel
//    @State private var recordName = ""
//    @State private var artistName = ""
//    var record: RecordItem
//    @State private var releaseYear: Int = 2024
//    @State private var selectedImage: UIImage? = nil
//    @State private var isImagePickerPresented: Bool = false
//    
//    @State private var editingMode: Bool = false
//    @State private var newPhoto: Bool = false
//    
//    @ObservedObject var genreManager = GenreManager()
//    
//    @State private var newGenre = ""
//    
//    @Environment(\.presentationMode) var presentationModeItem
//    
//    var ref: DatabaseReference! = Database.database().reference()
//    
//    var body: some View {
//        let id = record.id
//        
//            ZStack(alignment:.center) {
//                Image("Page-Background-2").resizable().ignoresSafeArea().aspectRatio(contentMode: .fill)
//                VStack{
////                    ZStack{
////                        Button(action:{
////                            viewModel.capturePhoto()
////                            newPhoto = true
////                        }) {
////                            // Show the photo capture screen
////                            ZStack{
////                                RoundedRectangle(cornerRadius:10).fill(iconWhite).aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
////                                if let capturedImage = viewModel.capturedImage {
////                                    // If photo captured, show
////                                    Image(uiImage: capturedImage)
////                                        .resizable()
////                                        .scaledToFill()
////                                        .frame(width:200,height: 200).padding(.all,10).clipped()
////                                }else{
////                                    // If photo already in db, show
////                                    Image(uiImage: record.photo)
////                                        .resizable()
////                                        .scaledToFill()
////                                        .frame(width:200,height: 200).clipped().padding(.all,10)
////                                }
////                            }.frame(width:200,height: 200)
////                                
////                            
////                        }.disabled(!editingMode)
////                        .sheet(isPresented: $viewModel.isImagePickerPresented) {
////                            ImagePicker(isPresented: $viewModel.isImagePickerPresented, imageCallback: viewModel.imagePickerCallback)
////                        }
////                        
////                    }.padding(.top,50)
//
//                    RecordImageDisplayView(viewModel: viewModel, record: record, editingMode: $editingMode)
//                    
//                    RecordFieldDisplayView(viewModel: viewModel, genreManager: genreManager, record: record, editingMode: $editingMode, recordName: $recordName, artistName: $artistName, releaseYear: $releaseYear)
//                    
////                    VStack{
////                        // Name Field
////                        HStack{
////                            HStack{
////                                Text("Name: ")
////                                Spacer()
////                            }.frame(width:screenWidth/4)
////                            if editingMode{
////                                TextField("Name", text: $recordName).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2)
////                                    .onAppear {
////                                        recordName = record.name
////                                    }
////                            }else{
////                                Text(record.name).padding().frame(width:screenWidth/2, alignment:.leading).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10))
////                            }
////                            Spacer()
////                        }
////                        
////                        // Artist Field
////                        HStack{
////                            HStack{
////                                Text("Artist: ")
////                                Spacer()
////                            }.frame(width:screenWidth/4)
////                            if editingMode{
////                                TextField("Artist", text: $artistName).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2).aspectRatio(contentMode: .fill)
////                                    .onAppear {
////                                        artistName = record.artist
////                                    }
////                            }else{
////                                Text(record.artist).padding().frame(width:screenWidth/2, alignment:.leading).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10))
////                            }
////                            Spacer()
////                        }
////                        
////                        // Release Year Field
////                        HStack{
////                            HStack{
////                                Text("Release Year: ")
////                                Spacer()
////                            }.frame(width:screenWidth/4)
////                            if editingMode{
////                                Picker("Year", selection: $releaseYear) {
////                                    ForEach((1500..<Int(Date.now.formatted(.dateTime.year()))!+1).reversed(), id:\.self) { year in
////                                        Text(String(year)).tag(year)
////                                    }
////                                }.onAppear {
////                                    releaseYear = record.releaseYear
////                                }
////                                .padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2,alignment:.leading)
////                            }else{
////                                Text(String(record.releaseYear)).padding().frame(width:screenWidth/2, alignment:.leading).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10))
////                            }
////                            Spacer()
////                        }
////                        
////                        // Genre Field
////                        HStack{
////                            HStack{
////                                Text("Genres: ")
////                                Spacer()
////                            }.frame(width:screenWidth/4)
//////                            VStack(alignment:.leading){
////                                if editingMode{
////                                    VStack(alignment:.leading){
////                                        HStack{
////                                            TextField("Genre", text: $newGenre).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10))
////                                            
////                                            Button(action: {
////                                                if newGenre != ""{
////                                                    genreManager.addGenre(newGenre)
////                                                    newGenre = ""
////                                                }
////                                            }) {
////                                                Image(systemName: "plus").foregroundColor(recordBlack).padding()
////                                            }
////                                        }
////                                        GenreDisplayView(genreManager:genreManager,displayOnly: false).frame(height:(genreManager.genres.count>0) ? 30 : 0).clipped()
////                                    }.padding().background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2,alignment:.leading)
////
////                                }else{
////                                    GenreDisplayView(genreManager:genreManager,displayOnly: true).frame(height:30).clipped().padding().background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2,alignment:.leading)
////
////                                }
//////                            }.padding().background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2,alignment:.leading)
////    //                        Spacer()
////                        }
////                        
////                    }.padding(.all, 20).background(lightWoodBrown).clipShape(RoundedRectangle(cornerRadius: 10)).padding(20)
//                    
//                    if editingMode{
//                        HStack{
//                            Button(action:{
//                                viewModel.resetPhoto()
//                                editingMode.toggle()
//                                genreManager.genres = record.genres
//                            }) {
//                                
//                                Text("Cancel").foregroundStyle(iconWhite)
//                                
//                            }.padding(20).background(pinkRed).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20)
//                            
//                            Button(action:{
//                                viewModel.editRecordEntry(id: id, recordName: recordName, artistName: artistName, releaseYear: releaseYear, newPhoto: newPhoto)
//                                viewModel.resetPhoto()
//                                
//                                presentationModeItem.wrappedValue.dismiss() // Dismiss the AddItemView
//                            }) {
//                                
//                                Text("Save Changes").foregroundStyle(iconWhite)
//                                
//                            }.padding(20).background(seaweedGreen).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20)
//                            
//                            
//                        }
//                    }else{
//                        Button(action:{
//                            editingMode.toggle()
//                        }) {
//                            
//                            Text("Edit Record").foregroundStyle(iconWhite)
//                            
//                        }.padding(20).background(pinkRed).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20)
//                    }
//                    
//                    Spacer()
//                                
//                }
//                
//            }.onAppear {
//                print("View appeared")
//                print("Editing mode: \(editingMode)")
//                print("Genres: \(genreManager.genres)")
//                genreManager.genres = record.genres
//                print("Genres after setting: \(genreManager.genres)")
//            }
//
//        
//    }
//    
//    
//}


//
//struct ShowRecordViewPageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ShowRecordView(viewModel:LibraryViewModel(),
//                       record:RecordItem(id: "E764B192-685B-4CA2-91DB-C21113A81CC7", name: "AA", artist: "C", releaseYear: 2005))
//    }
//}

struct GenreDisplayView: View{
    @ObservedObject var genreManager: GenreManager
    @Binding var displayOnly: Bool
    
    var body: some View{
        GeometryReader{geometry in
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
                                    if !displayOnly{
                                        Image(systemName: "xmark")
                                    }
                                }.padding(.horizontal)
                            }
                        }).disabled(displayOnly)
                    }
                }
            }.onAppear{
                print(genreManager.genres)
            }
        }
    }
}


