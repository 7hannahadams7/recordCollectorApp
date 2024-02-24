//
//  ArtistViews.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/12/24.
//
import Foundation
import SwiftUI
import Charts

// Shelf of 6 top artist record instances, with interaction
struct ArtistRecordShelf: View {
    @ObservedObject var viewModel: StatsViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    @Binding var isTabExpanded: Bool
    @State private var offset = 0.0

    var body: some View {
        
        GeometryReader { geometry in
            let recordStack: CGFloat = geometry.size.height/2*0.85
            let recordSpacing: CGFloat = min(recordStack/3,(geometry.size.width-3*recordStack)/3)
            
            let artistBarData = viewModel.topArtists.prefix(6)
            
            var popups: [CoverPhotoToPopupView] {
                var popupArray: [CoverPhotoToPopupView] = []

                for index in 0..<6 {
                    let popup: CoverPhotoToPopupView
                    var record = defaultRecordItems[index]
                    if index < artistBarData.count {
                        let recordID = artistBarData[index].records.first
                        record = viewModel.viewModel.recordDictionaryByID[recordID!]!
                    }
                    popup = CoverPhotoToPopupView(viewModel: viewModel.viewModel, spotifyController: spotifyController, genreManager: genreManager, record:record, size: recordStack)

                    popupArray.append(popup)
                }

                return popupArray
            }
            
            VStack{
                //Top Shelf
                ZStack(alignment:.bottom){
                    HStack(spacing:recordSpacing){
                        popups[0]
                        popups[1]
                        popups[2]
                    }.frame(height: recordStack)
                    Rectangle().frame(width:4*recordStack,height:0.15*recordStack).foregroundColor(lightWoodBrown).offset(y:3)
                    
                }.frame(height: recordStack).shadow(color:Color.black,radius:2)
                //Bottom Shelf
                ZStack(alignment:.bottom){
                    HStack(spacing:recordSpacing){
                        popups[3]
                        popups[4]
                        popups[5]
                    }.frame(height: recordStack)
                    Rectangle().frame(width:4*recordStack,height:0.15*recordStack).foregroundColor(lightWoodBrown).offset(y:3)
                    
                }.frame(height: recordStack).shadow(color:Color.black,radius:2)
            }.frame(width:geometry.size.width,height:geometry.size.height)
                .offset(x:offset)
                .onChange(of: isTabExpanded, initial: false) { value, value2 in
                    if value{
                        withAnimation(.easeOut(duration: 0.5).delay(0.2)){
                            offset = 0.0
                        }
                    }else{
                        withAnimation(.easeOut(duration: 0.5)){
                            offset = -screenWidth
                        }
                    }
                }
                .onAppear(perform: {
                    offset = -screenWidth
                    withAnimation(.easeOut(duration: 1.0).delay(0.2)){
                        offset = 0.0
                    }
                })
            
        }
    }
}

// Artist Information in bottom tab, both expanded and collapsed
struct ArtistInfoView: View {
    @ObservedObject var viewModel: StatsViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    @Binding var isTabExpanded: Bool
    @State private var offset = 0.0
    
    var body: some View {
        let artistBarData = viewModel.topArtists.prefix(6)
        let artistTotalData = viewModel.topArtists
        let totalArtists = artistTotalData.count
        
        GeometryReader { geometry in
                
            // Table Graphic
            VStack{
                if !isTabExpanded{
                    let minAmount = artistBarData.map { $0.amount }.min() ?? 1
                    let maxAmount = artistBarData.map { $0.amount }.max() ?? 1
                    let total = artistBarData.count
                    ZStack{
                        VStack{
                            ForEach(0..<min(6, artistBarData.count), id: \.self) { index in
                                            // Use the index to access elements in the subarray
                                let item = artistBarData[index]
                                ArtistCollapsedBarView(artist: item.artist, amount: item.amount, color: smallDisplayColors[index%6], total: total, minAmount: minAmount, maxAmount: maxAmount)
                                
                            }

                        }.padding(.vertical)
                    }.frame(width:geometry.size.width,height:geometry.size.height)
                        .background(isTabExpanded ? Color.clear: decorWhite)
                        .id(1)
                        .animation(.easeInOut(duration:0.5).delay(0.05),value:isTabExpanded)
                        .transition( .move(edge: .leading))
                }else{
                        ScrollView{
                            ForEach(artistTotalData.indices, id:\.self){index in
                                ArtistDetailRowView(artistItem:artistTotalData[index],viewModel:viewModel,spotifyController:spotifyController,genreManager:genreManager,color:fullDisplayColors[index%totalDisplayColors],positionProportion:fractionalValue(for: index, totalCount: totalArtists))
                                
                            }
                        }.padding(.vertical,30)
                            .id(2)
//                            .animation(.easeInOut(duration:0.5).delay(0.15))
                            .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                }
                
            }.frame(width:geometry.size.width,height:geometry.size.height).clipped()
                .offset(x:offset)
                .onAppear(perform: {
                    offset = -screenWidth
                    withAnimation(.easeOut(duration: 0.5).delay(0.4)){
                        offset = 0.0
                    }
                })
            
        }

    }
    
    private func fractionalValue(for index: Int, totalCount: Int) -> CGFloat {
        guard totalCount > 0 else {
            return 0.0
        }
        return CGFloat(totalCount - index) / CGFloat(totalCount)
    }
}

// Individual artist row for collapsed InfoView
struct ArtistCollapsedBarView: View{
    var artist: String
    var amount: Int
    var color: Color
    var total: Int
    var minAmount: Int
    var maxAmount: Int
    
    var body: some View{
        GeometryReader{geometry in

            let proportionalSize = CGFloat(amount - minAmount + 1) / CGFloat(maxAmount - minAmount + 1) * (geometry.size.width - 100) + 100
            
            HStack{
                HStack{
                    RoundedRectangle(cornerRadius: 25.0).fill(color).overlay(alignment: .trailing) {
                        Text(artist).bold().foregroundStyle(iconWhite).padding()
                    }
                    Text(String(amount))
                    Spacer()
                }.frame(width:proportionalSize,height:geometry.size.height).offset(x:-30)
                Spacer()
            }.background(decorWhite)
        }
    }
}

// Individual artist row with interactions, in InfoView when expanded
struct ArtistDetailRowView: View {
    var artistItem: (artist: String, amount: Int, records: [String]);
    @ObservedObject var viewModel: StatsViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    var color: Color
    var positionProportion: CGFloat
    @State private var expanded: Bool = false
    
    var body: some View {
        
        ZStack(alignment:.top){
            VStack{
                Spacer()
                ScrollView(.horizontal){
                    HStack{
                        ForEach(artistItem.records, id:\.self){recordID in
                            if let record = viewModel.viewModel.recordDictionaryByID[recordID]{
                                CoverPhotoToPopupView(viewModel: viewModel.viewModel, spotifyController: spotifyController, genreManager:genreManager, record: record,size:50)
                            }
                        }
                    }
                }.frame(height:60).padding(.all,5).padding(.horizontal,20).background(Rectangle().fill(color).opacity(0.3))
            }.frame(height:expanded ? 150:70).opacity(expanded ? 1.0 : 0.0)
            Button(action:{
                withAnimation(.easeInOut(duration: 0.5).delay(0.15)) {
                    expanded.toggle()
                }
            }){
                HStack{
                    HStack{
                        ZStack{
                            RoundedRectangle(cornerRadius: 25.0).fill(color).overlay(alignment: .trailing) {
                                Text(artistItem.artist).bold().foregroundStyle(iconWhite).padding()
                            }
                        }
                        Text(String(artistItem.amount)).padding()
                        Spacer()
                    }.padding(5).frame(width:screenWidth*0.75+100*positionProportion,height:75).offset(x:-30)
                    Spacer()
                }.background(decorWhite)
            }
        }.padding(.trailing, 20.0).frame(height:expanded ? 150:75)
    }
}

