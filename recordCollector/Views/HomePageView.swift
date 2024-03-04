//
//  HomePageView.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/8/24.
//

import SwiftUI
import Combine

struct HomePageView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    
    let topStack: CGFloat = 100
    let bottomStack: CGFloat = 125

    @State private var isAddItemSheetPresented = false
    @StateObject private var photoDisplayManager: RecordShelfDisplayManager
    @State private var timer: Timer?
    
    @State var presentingListener: Bool = false

    var body: some View {
        
        // Pull current photos to display
        let photoPopups = photoPopupEntries(shownRecords: photoDisplayManager.shownRecords)
        
        NavigationView{
            
            //Background Decor
            ZStack{
                
                
                //Background Image
                Image("Main-Page-Background-1").resizable().edgesIgnoringSafeArea(.all)
                
                //Foreground Decor (with shelves and records)
                VStack{
                    
                    Spacer()
                    
                    //Top Record Shelf
                    ZStack(alignment:.bottom){
                        
                        // Records
                        HStack{
                            photoPopups[0]
                            photoPopups[1]
                            photoPopups[2]
                        }.shadow(color:Color.black,radius:2).offset(y:-10)
                        
                        //Shelf
                        RoundedRectangle(cornerRadius:2).fill(lightWoodBrown).shadow(color:recordBlack,radius:2).frame(height:20).padding(.horizontal)
                        
                    }.frame(height: topStack+25)
                    
                    //Bottom Shelves
                    ZStack(alignment:.top){
                        
                        //Records
                        HStack{
                            photoPopups[3]
                            photoPopups[4]
                            photoPopups[5]
                            photoPopups[6]
                            
                        }.shadow(color:Color.black,radius:3).offset(y:-bottomStack+20)
                        
                        // Front Shelving Display
                        Image("frontShelves-1").resizable().aspectRatio(contentMode: .fit)
                        
                    }.frame(width: screenWidth, height:screenWidth+bottomStack+50,alignment:.bottom)
                    
                }.ignoresSafeArea()
                
                //Add New Button
                VStack{
                    HStack{
                        Spacer()
                        NavigationLink(destination: AddRecordView(viewModel:viewModel,genreManager:genreManager)) {
                            Image("AddButton").resizable().frame(width:80,height:80).shadow(color:Color.black,radius:2)
                        }
                    }.padding(.trailing,15)
                    Spacer()
                }
                
                
            }
            
        }.onChange(of: presentingListener, { _, presenting in
            if presentingListener{
                // Pause timer when a ShowRecordView instance displayed
                timer?.invalidate()
            } else {
                // Restart timer
                timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 1.0)) {
                        photoDisplayManager.updateArray()
                    }
                }
            }
        })
        .onAppear {
            // Start update timer
            timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                withAnimation(.easeInOut(duration:1.0)) {
                    photoDisplayManager.updateArray()
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    init(viewModel: LibraryViewModel, spotifyController: SpotifyController, genreManager: GenreManager) {
        self.viewModel = viewModel
        self.spotifyController = spotifyController
        self.genreManager = genreManager
        self._photoDisplayManager = StateObject(wrappedValue: RecordShelfDisplayManager(viewModel: viewModel))
    }
    
    // creating PhotoToPopup instances with photoDisplayManager listening, UI updates automatically when .updateArray() called
    private func photoPopupEntries(shownRecords: [RecordItem]) -> [CoverPhotoToPopupView] {
        
        var photoArray: [CoverPhotoToPopupView] = []
        for (index, record) in shownRecords.enumerated() {
            let size = CGFloat((index < 3) ? topStack : bottomStack)
            let photoToPopup = CoverPhotoToPopupView(viewModel: viewModel, spotifyController: spotifyController, genreManager: genreManager, record: record, size: size, presentingListener: $presentingListener)
            photoArray.append(photoToPopup)
        }

        return photoArray
    }
        
}
            
struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView(viewModel:testViewModel,spotifyController:SpotifyController(),genreManager:GenreManager()).onAppear{
            testViewModel.refreshData()
        }
    }
}
