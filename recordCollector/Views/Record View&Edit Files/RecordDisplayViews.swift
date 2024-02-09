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
    @Binding var newCoverPhoto: Bool
    @Binding var newDiskPhoto: Bool
    
    @Binding var editingMode: Bool
    
    @State private var selectedSourceType: ImagePicker.SourceType? = .camera
    @State private var isCoverPhotoPopupPresented: Bool = false
    @State private var isDiskPhotoPopupPresented: Bool = false
    
    @State private var lpOffset: CGFloat = 0.0
    @State private var dragging = false
    
    var body: some View{
        if editingMode{
            ZStack{
                // Cover Photo Change Button
                Button(action:{
                    viewModel.whichPhoto = "Cover"
                    isCoverPhotoPopupPresented.toggle()
                    newCoverPhoto = true
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
                    isDiskPhotoPopupPresented.toggle()
                    newDiskPhoto = true
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
                // Popup for cover photo
                .popover(isPresented: $isCoverPhotoPopupPresented, arrowEdge: .bottom) {
                    PhotoSourceSelectionPopup(isPhotoSourcePopupPresented: $isCoverPhotoPopupPresented,
                          newPhoto: $newCoverPhoto) {
                        selectedSourceType = .photoLibrary
                        isCoverPhotoPopupPresented.toggle()
                        viewModel.capturePhoto()
                    } onCameraSelected: {
                        selectedSourceType = .camera
                        isCoverPhotoPopupPresented.toggle()
                        viewModel.capturePhoto()
                    }
                }
                // Popup for disk photo
                .popover(isPresented: $isDiskPhotoPopupPresented, arrowEdge: .bottom) {
                    PhotoSourceSelectionPopup(isPhotoSourcePopupPresented: $isDiskPhotoPopupPresented,
                          newPhoto: $newDiskPhoto) {
                        selectedSourceType = .photoLibrary
                        isDiskPhotoPopupPresented.toggle()
                        viewModel.capturePhoto()
                    } onCameraSelected: {
                        selectedSourceType = .camera
                        isDiskPhotoPopupPresented.toggle()
                        viewModel.capturePhoto()
                    }
                }
                .sheet(isPresented: $viewModel.isImagePickerPresented) {
                    ImagePicker(isPresented: $viewModel.isImagePickerPresented, imageCallback: viewModel.imagePickerCallback, sourceType: selectedSourceType!)
                }
        }else{
            // Display images with swipe view capability, no button function
            ZStack{
                // Disc Photo
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
                
                // Cover Photo
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
    @Binding var dateAdded: Date
    @Binding var isBand: Bool
    
    @State private var newGenre = ""
    
    @Binding var showAlert: Bool
    @Binding var listeningMode: Bool
    
    @State private var isDatePickerVisible: Bool = false
    
    
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
            if editingMode{
                
                // Name Field
                HStack{
                    // Label
                    HStack{
                        Text("Name: ")
                        Spacer()
                    }.frame(width:screenWidth/4)
                    // Text Field
                    TextField("Name", text: $recordName).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2)
                        .shadow(color:(showAlert && recordName.isEmpty) ? Color.red : Color.clear, radius: 10)
                    Spacer()
                }
                
                // Artist Field
                HStack{
                    // Label
                    HStack{
                        Text("Artist: ")
                        Spacer()
                    }.frame(width:screenWidth/4)
                    // Text Field
                    TextField("Artist", text: $artistName).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2-40).aspectRatio(contentMode: .fill)
                        .shadow(color:(showAlert && artistName.isEmpty) ? Color.red : Color.clear, radius: 5)
                    // Band Selector
                    VStack{
                        Text("Band").font(.system(size:12))
                        Button {
                            isBand.toggle()
                        } label: {
                            if isBand{
                                Image(systemName:"checkmark.square.fill").foregroundColor(grayBlue)
                            }else{
                                Image(systemName:"checkmark.square").foregroundColor(grayBlue)
                            }
                        }
                    }
                    Spacer()
                }
                
                // Release Year Field
                HStack{
                    // Label
                    HStack{
                        Text("Release Year: ").minimumScaleFactor(0.8)
                        Spacer()
                    }.frame(width:screenWidth/4)
                    // Year Picker
                    Picker("Year", selection: $releaseYear) {
                        ForEach((1500..<Int(Date.now.formatted(.dateTime.year()))!+1).reversed(), id:\.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2,alignment:.leading)
                    Spacer()
                }
                
                //Genre Field
                HStack{
                    // Label
                    HStack{
                        Text("Genres: ")
                        Spacer()
                    }.frame(width:screenWidth/4)
                    // Genre Field
                    VStack(alignment:.leading){
                        HStack{
                            // Entry Field
                            ZStack(alignment: .trailing){
                                TextField("Genre", text: $newGenre).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10))
                                Button(action: {
                                    newGenre = ""
                                }){
                                    Image(systemName: "xmark").foregroundStyle(decorWhite).padding()
                                }
                            }
                            // Add Button
                            Button(action: {
                                if newGenre != ""{
                                    genreManager.addGenre(newGenre)
                                    newGenre = ""
                                }
                            }) {
                                Image(systemName: "plus").foregroundColor(recordBlack).padding()
                            }.frame(width:15)
                        }
                        // Genre List View
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
                            // Dropdown list of selectable genres
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
                    newGenre = "" // Reset text field
                }
                
                // Date Added Field
                HStack{
                    // Label
                    HStack{
                        Text("Date Added: ").minimumScaleFactor(0.8)
                        Spacer()
                    }.frame(width:screenWidth/4)
                    // Date Picker
                    DatePicker("", selection: $dateAdded, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                        .padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2,alignment:.leading)
                    Spacer()
                }
                
                // Location Bought Field
                HStack{
                    // Label
                    HStack{
                        Text("Location: ")
                        Spacer()
                    }.frame(width:screenWidth/4)
                    // Text Field
                    TextField("Location", text: $recordName).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2)
                        .shadow(color:(showAlert && recordName.isEmpty) ? Color.red : Color.clear, radius: 10)
                    Spacer()
                }
                
            }else{
                
                VStack(alignment:.leading){
                    HStack{
                        VStack(alignment:.leading){
                            Text(recordName).headlineText()
                            Text(artistName + (isBand ? "" : "ª")).mainText()
                            Text("Released: " +  String(releaseYear)).subtitleText()
                        }.padding(.bottom,5)
                        Spacer()
                        if !listeningMode{
                            Button(action:{
                                listeningMode.toggle()
                            }){
                                Image("playButton").resizable().frame(width:50,height:50)
                            }
                        }
                    }
                    VStack(alignment:.leading){
                        Text("Genres: ").italicSubtitleText()
                        ScrollView(.horizontal) {
                            HStack{
                                ForEach(genreManager.genres.reversed(), id: \.self){genre in
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 5).foregroundColor(iconWhite)
                                        HStack{
                                            Text(genre).italicSubtitleText().onAppear{
                                                print(genre)
                                            }
                                        }.padding(.horizontal)
                                    }.frame(height:30)
                                }
                            }
                        }
                    }.padding(.vertical,5)
                    .onAppear{
                        genreManager.genres = record?.genres ?? []
                    }
                    VStack(alignment:.leading){
                        Text("Date Added: " + (Date.dateToString(date: dateAdded))).subtitleText()
                        Text("Location Bought: " + (record?.name ?? "")).subtitleText()
                    }.padding(.vertical,5)
                }
            }
            
        }.padding(.all, 20).background(lightWoodBrown).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20).padding(.top,15).padding(.bottom,5)
            .onAppear{
                recordName = record?.name ?? ""
                artistName = record?.artist ?? ""
                releaseYear = record?.releaseYear ?? 2024
                dateAdded = String.stringToDate(from: record?.dateAdded ?? "01-01-0001")!
                isBand = record?.isBand ?? false
                genreManager.genres = record?.genres ?? []
            }
            .onChange(of: editingMode) { _, _ in
                genreManager.genres = record?.genres ?? []
                print("IN DISPLAY: ", genreManager.genres)
            }
        
    }
    
    
}





