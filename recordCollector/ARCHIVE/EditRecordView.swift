//
//  AddRecordView.swift
//  test3
//
//  Created by Hannah Adams on 1/8/24.
//

import SwiftUI
import FirebaseDatabase
import FirebaseStorage

struct EditRecordView: View {
    @ObservedObject var viewModel: LibraryViewModel
    var record: RecordItem
    @State var recordName: String = ""
    @State var artistName: String = ""
    @State var releaseYear: Int = 0
    
    @State private var isImagePickerPresented: Bool = false
    @Environment(\.presentationMode) var presentationModeEditing
    
    @State private var newPhoto: Bool = false
    
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
                        if let capturedImage = viewModel.capturedImage {
                            // If photo captured, show
                            Image(uiImage: capturedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width:100,height: 100)
                                .padding(.trailing,10)
                        }else if record.photo != nil{
                            // If photo already in db, show
                            Image(uiImage: record.photo)
                                .resizable()
                                .scaledToFit()
                                .frame(width:100,height: 100)
                                .padding(.trailing,10)
                        }else{
                            // Blank button
                            ZStack{
                                RoundedRectangle(cornerRadius:10).fill(iconWhite).aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                Rectangle().fill(decorWhite).padding(.all,10)
                                Image(systemName:"camera").font(.system(size: 40)).foregroundStyle(iconWhite)
                            }.frame(width:200,height: 200)
                            
                        }
                    }.sheet(isPresented: $viewModel.isImagePickerPresented) {
                        ImagePicker(isPresented: $viewModel.isImagePickerPresented, imageCallback: viewModel.imagePickerCallback)
                    }
                    
                }.padding(.top,50)

                VStack{

                    HStack{
                        HStack{
                            Text("Name: ")
                            Spacer()
                        }.frame(width:screenWidth/4)
                        TextField("Name", text: $recordName).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2)        
                            .onAppear {
                                recordName = record.name
                            }
                        Spacer()
                    }
                    HStack{
                        HStack{
                            Text("Artist: ")
                            Spacer()
                        }.frame(width:screenWidth/4)
                        TextField("Artist", text: $artistName).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2).aspectRatio(contentMode: .fill)
                            .onAppear {
                                artistName = record.artist
                            }
                        Spacer()
                    }
                    HStack{
                        HStack{
                            Text("Release Year: ")
                            Spacer()
                        }.frame(width:screenWidth/4)
                        Picker("Year", selection: $releaseYear) {
                            ForEach((1500..<Int(Date.now.formatted(.dateTime.year()))!+1).reversed(), id:\.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }.onAppear {
                            releaseYear = record.releaseYear
                        }
                        .padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2,alignment:.leading)
                        Spacer()
                    }
                    
                }.padding(.all, 20).background(lightWoodBrown).clipShape(RoundedRectangle(cornerRadius: 10)).padding(20)
                
                HStack{
                    Button(action:{
                        viewModel.resetPhoto()
                        presentationModeEditing.wrappedValue.dismiss() // Dismiss the AddItemView
                    }) {
                        
                        Text("Cancel").foregroundStyle(iconWhite)
                        
                    }.padding(20).background(pinkRed).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20)
                    
                    Button(action:{
                        viewModel.editRecordEntry(id: id, recordName: recordName, artistName: artistName, releaseYear: releaseYear, newPhoto: newPhoto)
                        viewModel.resetPhoto()
                        presentationModeEditing.wrappedValue.dismiss() // Dismiss the AddItemView
                    }) {
                        
                        Text("Save Changes").foregroundStyle(iconWhite)
                        
                    }.padding(20).background(seaweedGreen).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20)
                }
                Spacer()
                            
            }
            
        }
    }
    
    
}


//
//struct EditRecordViewPageView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditRecordView(viewModel:LibraryViewModel(),
//                       record:RecordItem(id: "E764B192-685B-4CA2-91DB-C21113A81CC7", name: "AA", artist: "C", releaseYear: 2005))
//    }
//}

