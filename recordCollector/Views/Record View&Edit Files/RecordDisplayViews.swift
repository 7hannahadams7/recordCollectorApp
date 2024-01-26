//
//  AddRecordView.swift
//  test3
//
//  Created by Hannah Adams on 1/8/24.
//

import SwiftUI
import FirebaseDatabase
import FirebaseStorage


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
                
                ZStack{
                    RoundedRectangle(cornerRadius:10).fill(iconWhite).aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                    if let capturedImage = viewModel.capturedImage {
                        // If photo captured, show
                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width:200,height: 200).clipped().padding(.all,10)
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
            
        }
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
    
    @Binding var showAlert: Bool
    
    var showList: Bool {
        return !newGenre.isEmpty
    }
    
    var filteredGenres: [String] {
        return viewModel.fullGenres.filter { $0.lowercased().contains(newGenre.lowercased()) }
    }
    
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
                        }.shadow(color:(showAlert && recordName.isEmpty) ? Color.red : Color.clear, radius: 10)
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
                        }.shadow(color:(showAlert && artistName.isEmpty) ? Color.red : Color.clear, radius: 5)
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
                                ZStack(alignment: .trailing){
                                    TextField("Genre", text: $newGenre).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10))
                                    Button(action: {
                                        print(filteredGenres)
                                        newGenre = ""
                                    }){
                                        Image(systemName: "xmark").foregroundStyle(decorWhite).padding()
                                    }
                                }
                                
                                Button(action: {
                                    if newGenre != ""{
                                        genreManager.addGenre(newGenre)
                                        newGenre = ""
                                    }
                                }) {
                                    Image(systemName: "plus").foregroundColor(recordBlack).padding()
                                }.frame(width:15)
                            }
                        }
                        ZStack(alignment:.leading){
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
                                        }).disabled(!editingMode).frame(height:30)
                                    }
                                }
                            }.frame(height:40)
                            if showList {
                                    List{
                                        ForEach(filteredGenres, id: \.self) { genre in
                                            Button(action: {
                                                newGenre = genre // Auto-complete the text field with the selected genre
                                            }) {
                                                Text(genre).font(.system(size:15)).clipped()
                                            }/*.listRowInsets(EdgeInsets(top:-20,leading:10,bottom:-20,trailing:10))*/
                                        }
                                    }.listStyle(.inset).padding(EdgeInsets(top: -10, leading: 0, bottom: -10, trailing: 0)).background(iconWhite).frame(height: showList ? 40 : 0)
                                    
                            }
                        }
                    }.padding(10).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2,alignment:.leading)
                Spacer()
            }
            .onChange(of: editingMode) {
                newGenre = ""
            }
            
        }.padding(.all, 20).background(lightWoodBrown).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20).padding(.top,15).padding(.bottom,5)
        
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




