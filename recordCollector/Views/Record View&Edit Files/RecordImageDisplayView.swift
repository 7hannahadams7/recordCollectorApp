//
//  RecordImageDisplayView.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/18/24.
//

import SwiftUI
import FirebaseDatabase
import FirebaseStorage

// Displays Cover and Disc photos, with slide animation and editingMode display
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
                    PhotoSourceSelectionView(isPhotoSourcePopupPresented: $isCoverPhotoPopupPresented,
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
                    PhotoSourceSelectionView(isPhotoSourcePopupPresented: $isDiskPhotoPopupPresented,
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
