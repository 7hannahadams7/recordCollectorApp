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
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var ref: DatabaseReference! = Database.database().reference()
    
    var body: some View {
        
        ZStack(alignment:.center) {
            Image("Page-Background-2").resizable().ignoresSafeArea().aspectRatio(contentMode: .fill)
            VStack{
                ZStack{
                    Button(action:{viewModel.capturePhoto()}) {
                        // Show the photo capture screen
                        if let capturedImage = viewModel.capturedImage {
                            Image(uiImage: capturedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width:100,height: 100)
                                .padding(.trailing,10)
                        }else{
                            ZStack{
                                RoundedRectangle(cornerRadius:10).fill(iconWhite).aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                Rectangle().fill(decorWhite).padding(.all,10)
                                Image(systemName:"camera").font(.system(size: 40)).foregroundStyle(iconWhite)
                            }.frame(width:200,height: 200)

                        }
                    }
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
                        TextField("Name", text: $recordName).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2)
                        Spacer()
                    }
                    HStack{
                        HStack{
                            Text("Artist: ")
                            Spacer()
                        }.frame(width:screenWidth/4)
                        TextField("Artist", text: $artistName).padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2).aspectRatio(contentMode: .fill)
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
                        }
                        .padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10)).frame(width:screenWidth/2,alignment:.leading)
                        Spacer()
                    }
                    
                }.padding(.all, 20).background(lightWoodBrown).clipShape(RoundedRectangle(cornerRadius: 10)).padding(20)
                
                Button(action:{
                    viewModel.uploadRecord(recordName: recordName, artistName: artistName, releaseYear: releaseYear)

                    presentationMode.wrappedValue.dismiss() // Dismiss the AddItemView
                }) {
                    
                    Text("Add Record").foregroundStyle(iconWhite)

                }.padding(20).background(pinkRed).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal,20)
                
                Spacer()
                            
            }
            
        }.onDisappear(){
            viewModel.resetPhoto()
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

