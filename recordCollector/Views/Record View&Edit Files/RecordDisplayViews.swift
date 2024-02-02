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
    
    @State private var selectedSourceType: ImagePicker.SourceType? = .camera
    @State private var isPhotoSourcePopupPresented: Bool = false
    
    @State private var lpOffset: CGFloat = 0.0
    @State private var dragging = false
    
    var body: some View{
        if editingMode{
            ZStack{
                // Cover Photo Change Button
                Button(action:{
                    viewModel.whichPhoto = "Cover"
                    isPhotoSourcePopupPresented.toggle()
                    newPhoto = true
                }) {
                    ZStack{
                        RoundedRectangle(cornerRadius:10).fill(iconWhite).aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        if let capturedImage = viewModel.capturedCoverImage {
                            // If photo captured, show
                            Image(uiImage: capturedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width:150,height: 150).clipped().padding(.all,10)
                        }else if record != nil{
                            Image(uiImage: record!.coverPhoto).resizable()
                                .scaledToFill()
                                .frame(width:150,height: 150).clipped().padding(.all,10)
                        } else{
                            Image("TakePhoto")
                                .resizable()
                                .scaledToFill()
                                .frame(width:150,height: 150).clipped().padding(.all,10)
                        }
                    }
                }.frame(width:150,height: 150).offset(x:-10,y:-10)
                
                // Disc Photo Change Button
                Button(action:{
                    viewModel.whichPhoto = "LP"
                    isPhotoSourcePopupPresented.toggle()
                    newPhoto = true
                }) {
                    ZStack{
                        Circle().fill(iconWhite).aspectRatio(contentMode:.fill)
                        if let capturedImage = viewModel.capturedLPImage {
                            // If photo captured, show
                            Image(uiImage: capturedImage)
                                .resizable()
                                .scaledToFill()
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/).frame(width:100,height: 100).clipped().padding(.all,10)
                        }else if record != nil{
                            Image(uiImage: record!.discPhoto).resizable()
                                .scaledToFill()
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/).frame(width:100,height: 100).clipped().padding(.all,10)
                        } else{
                            Image("TakePhoto")
                                .resizable()
                                .scaledToFill()
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/).frame(width:100,height: 100).padding(.all,10)
                        }
                        
                    }
                }.frame(width:100,height:100).offset(x:50,y: 50)
                
            }.frame(width:screenWidth,height:200)
                .popover(isPresented: $isPhotoSourcePopupPresented, arrowEdge: .bottom) {
                    PhotoSourceSelectionPopup(isPhotoSourcePopupPresented: $isPhotoSourcePopupPresented,
                          newPhoto: $newPhoto) {
                        selectedSourceType = .photoLibrary
                        isPhotoSourcePopupPresented.toggle()
                        viewModel.capturePhoto()
                    } onCameraSelected: {
                        selectedSourceType = .camera
                        isPhotoSourcePopupPresented.toggle()
                        viewModel.capturePhoto()
                    }
                }
                .sheet(isPresented: $viewModel.isImagePickerPresented) {
                    ImagePicker(isPresented: $viewModel.isImagePickerPresented, imageCallback: viewModel.imagePickerCallback, sourceType: selectedSourceType!)
                }
        }else{
            // Display images with swipe view capability, no button function
            ZStack{
                // Disc Photo Change Button
                    ZStack{
                        Circle().fill(iconWhite).aspectRatio(contentMode:.fill)
                        if let capturedImage = viewModel.capturedCoverImage {
                            // If photo captured, show
                            Image(uiImage: capturedImage)
                                .resizable()
                                .scaledToFill()
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/).frame(width:190,height: 190).clipped().padding(.all,10)
                        }else if record != nil{
                            Image(uiImage: record!.discPhoto).resizable()
                                .scaledToFill()
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/).frame(width:190,height: 190).clipped().padding(.all,10)
                        } else{
                            Image("TakePhoto")
                                .resizable()
                                .scaledToFill()
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/).frame(width:190,height: 190).padding(.all,10)
                        }
                        
                    }.frame(width:190,height:190).offset(x:lpOffset+25.0)
                    .disabled(!editingMode && !dragging)
                
                // Cover Photo Change Button
                    ZStack{
                        RoundedRectangle(cornerRadius:10).fill(iconWhite).aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        if let capturedImage = viewModel.capturedLPImage {
                            // If photo captured, show
                            Image(uiImage: capturedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width:200,height: 200).clipped().padding(.all,10)
                        }else if record != nil{
                            Image(uiImage: record!.coverPhoto).resizable()
                                .scaledToFill()
                                .frame(width:200,height: 200).clipped().padding(.all,10)
                        } else{
                            Image("TakePhoto")
                                .resizable()
                                .scaledToFill()
                                .frame(width:200,height: 200).clipped().padding(.all,10)
                        }
                }.frame(width:200,height: 200).offset(x: -lpOffset)
                    .disabled(!editingMode && !dragging)
                
            }.frame(width:screenWidth,height:200)
                .gesture(DragGesture()
                    .onChanged { value in
                        withAnimation {
                            self.dragging = true
                            self.lpOffset = max(value.translation.width,0.0)
                        }
                    }
                    .onEnded { value in
                        withAnimation {
                            self.dragging = false
                            if value.predictedEndTranslation.width > 0 {
                                // User swiped right
                                self.lpOffset = 50.0
                            } else {
                                // User swiped left
                                self.lpOffset = 0.0
                            }
                        }
                    }
                )
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
        // Show genre options to choose from if user is typing and there are genres available
        return !newGenre.isEmpty && !filteredGenres.isEmpty
    }
    
    var filteredGenres: [String] {
        // Filter previous genres to include only those with words that start with text input and that aren't already included in genre list for current item
        let lowercasedInput = newGenre.lowercased()

        return viewModel.fullGenres
            .filter { genre in
                let words = genre.lowercased().components(separatedBy: " ")
                return words.contains { $0.hasPrefix(lowercasedInput) }
            }
            .filter { !genreManager.genres.contains($0) }
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
                    Text("Release Year: ").minimumScaleFactor(0.8)
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
                            }.frame(height:50)
                            if showList {
                                    List{
                                        ForEach(filteredGenres, id: \.self) { genre in
                                            Button(action: {
                                                newGenre = genre // Auto-complete the text field with the selected genre
                                                genreManager.addGenre(newGenre)
                                                newGenre = ""
                                            }) {
                                                Text(genre).font(.system(size:15)).clipped()
                                            }/*.listRowInsets(EdgeInsets(top:-20,leading:10,bottom:-20,trailing:10))*/
                                        }
                                    }.listStyle(.inset)/*.padding(EdgeInsets(top: -10, leading: 0, bottom: -10, trailing: 0))*/.background(iconWhite).frame(height: showList ? 50 : 0).clipShape(RoundedRectangle(cornerRadius: 10))
                                    
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
        if !(genres.contains(genre)){
            genres.append(genre)
        }
    }

    func removeGenre(_ genre: String) {
        genres.removeAll { $0 == genre }
    }
}




