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
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    
    @State private var editingMode: Bool = false
    @State private var newPhoto: Bool = false
    
    @Environment(\.presentationMode) var presentationModeItem
    
    var ref: DatabaseReference! = Database.database().reference()
    
    var body: some View {
        let id = record.id
        
            ZStack(alignment:.center) {
                Image("Page-Background-2").resizable().ignoresSafeArea().aspectRatio(contentMode: .fill)
                VStack{
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
                                }else if record.photo != nil{
                                    // If photo already in db, show
                                    Image(uiImage: record.photo!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:200,height: 200).clipped().padding(.all,10)
                                }else{
                                    // Blank button
                                    Rectangle().fill(decorWhite).padding(.all,10)
                                    Image(systemName:"camera").font(.system(size: 40)).foregroundStyle(iconWhite)
                                }
                            }.frame(width:200,height: 200)
                                
                            
                        }.disabled(!editingMode)
                        .sheet(isPresented: $viewModel.isImagePickerPresented) {
                            ImagePicker(isPresented: $viewModel.isImagePickerPresented, imageCallback: viewModel.imagePickerCallback)
                        }
                        
                    }.padding(.top,50)

                    VStack{

                        HStack{
                            HStack{
                                Text("Name: ")
                                Spacer()
                            }.frame(width:screenWidth/4)
                            if editingMode{
                                TextField("Name", text: $recordName).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2)
                                    .onAppear {
                                        recordName = record.name
                                    }
                            }else{
                                Text(record.name).padding().frame(width:screenWidth/2, alignment:.leading).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            Spacer()
                        }
                        HStack{
                            HStack{
                                Text("Artist: ")
                                Spacer()
                            }.frame(width:screenWidth/4)
                            if editingMode{
                                TextField("Artist", text: $artistName).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2).aspectRatio(contentMode: .fill)
                                    .onAppear {
                                        artistName = record.artist
                                    }
                            }else{
                                Text(record.artist).padding().frame(width:screenWidth/2, alignment:.leading).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            Spacer()
                        }
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
                                    releaseYear = record.releaseYear
                                }
                                .padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2,alignment:.leading)
                            }else{
                                Text(String(record.releaseYear)).padding().frame(width:screenWidth/2, alignment:.leading).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            Spacer()
                        }
                        
                    }.padding(.all, 20).background(lightWoodBrown).clipShape(RoundedRectangle(cornerRadius: 10)).padding(20)
                    
                    if editingMode{
                        HStack{
                            Button(action:{
                                viewModel.resetPhoto()
                                editingMode.toggle()
                            }) {
                                
                                Text("Cancel").foregroundStyle(iconWhite)
                                
                            }.padding(20).background(pinkRed).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20)
                            
                            Button(action:{
                                viewModel.editRecordEntry(id: id, recordName: recordName, artistName: artistName, releaseYear: releaseYear, newPhoto: newPhoto)
                                viewModel.resetPhoto()
                                
                                presentationModeItem.wrappedValue.dismiss() // Dismiss the AddItemView
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
                
            }

//            ZStack(alignment:.center) {
//                Image("Page-Background-2").resizable().ignoresSafeArea().aspectRatio(contentMode: .fill)
//                VStack{
//                    ZStack{
//                        ZStack{
//                            RoundedRectangle(cornerRadius:10).fill(iconWhite).aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
//                            if record.photo != nil{
//                                Image(uiImage: record.photo!).resizable().aspectRatio(contentMode: .fit).padding(.all,10).foregroundStyle(iconWhite)
//                            }else{
//                                Rectangle().fill(decorWhite).padding(.all,10)
//                                Image(systemName:"camera").font(.system(size: 40)).foregroundStyle(iconWhite)
//                            }
//                        }.frame(width:200,height: 200)
//                        
//                    }.padding(.top,50)
//                    
//                    VStack{
//                        
//                        HStack{
//                            HStack{
//                                Text("Name: ")
//                                Spacer()
//                            }.frame(width:screenWidth/4)
//                            Text(record.name).padding().frame(width:screenWidth/2, alignment:.leading).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10))
//                            Spacer()
//                        }
//                        HStack{
//                            HStack{
//                                Text("Artist: ")
//                                Spacer()
//                            }.frame(width:screenWidth/4)
//                            Text(record.artist).padding().frame(width:screenWidth/2, alignment:.leading).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10))
//                            Spacer()
//                        }
//                        HStack{
//                            HStack{
//                                Text("Release Year: ")
//                                Spacer()
//                            }.frame(width:screenWidth/4)
//                            Text(String(record.releaseYear)).padding().frame(width:screenWidth/2, alignment:.leading).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 10))
//                            Spacer()
//                        }
//                        
//                    }.padding(.all, 20).background(lightWoodBrown).clipShape(RoundedRectangle(cornerRadius: 10)).padding(20)
                    
//                    Button(action:{
//                        editingMode.toggle()
//                    }) {
//                        
//                        Text("Edit Record").foregroundStyle(iconWhite)
//                        
//                    }.padding(20).background(pinkRed).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20)
                    
                    Spacer()
                    
                
                
//            }
//        }
        
    }
    
    
}



struct ShowRecordViewPageView_Previews: PreviewProvider {
    static var previews: some View {
        ShowRecordView(viewModel:LibraryViewModel(),
                       record:RecordItem(id: "E764B192-685B-4CA2-91DB-C21113A81CC7", name: "AA", artist: "C", releaseYear: 2005))
    }
}

