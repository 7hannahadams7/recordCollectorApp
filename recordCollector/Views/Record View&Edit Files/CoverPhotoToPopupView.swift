//
//  PhotoInteractions.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/14/24.
//

import Foundation
import SwiftUI

// Takes RecordItem and creates interactive cover photo of size: size that triggers a ShowRecordView popup
struct CoverPhotoToPopupView: View{
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager

    var record: RecordItem
    var size: CGFloat
    
    @State var showRecordPopupPresented: Bool = false
    
    // Listener for ShowRecordView popup on HomePageView only (to pause updates while presenting)
    @Binding var presentingListener: Bool
    
    init(viewModel: LibraryViewModel, spotifyController: SpotifyController, genreManager: GenreManager, record: RecordItem, size: CGFloat, presentingListener: Binding<Bool>? = Binding.constant(false)) {
        self.viewModel = viewModel
        self.spotifyController = spotifyController
        self.genreManager = genreManager
        self.record = record
        self.size = size
        _presentingListener = presentingListener!
    }
    
    var body: some View{
        VStack{
            Button{
                showRecordPopupPresented = true
                presentingListener = true
            }label:{
//                let photo = viewModel.fetchPhotoByID(id: record.id)
                // BUTTON WITH NAVIGATION HERE
                Image(uiImage: record.coverPhoto).resizable().frame(width:size, height:size).scaledToFill().clipped()
            }
        }.popover(isPresented: $showRecordPopupPresented, content: {
            ZStack{
                Color(woodBrown)
                ShowRecordView(viewModel: viewModel, spotifyController: spotifyController, record: record, genreManager: genreManager).padding(.top)
            }.onDisappear {
                presentingListener = false
            }
        })
    }
}
