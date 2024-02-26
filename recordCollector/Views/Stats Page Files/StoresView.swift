//
//  StoresView.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/25/24.
//

import Foundation
import SwiftUI
import MapKit

struct StoresInfoView: View {
    @ObservedObject var statsViewModel: StatsViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    @Binding var isTabExpanded: Bool
    @State private var offset = 0.0

    @State private var tapped: String = ""
    @State private var infoExpanded = false
    @State private var infoColor: Color = seaweedGreen
    
    var body: some View {
        let storeCollapsedData = statsViewModel.topStores.prefix(6)
        
        GeometryReader { geometry in
            let infoRowWidth: CGFloat = geometry.size.width/2-10
            let infoIconSize: CGFloat = geometry.size.height/4
            // Table Graphic
            VStack{
                if !isTabExpanded{
                        // Collapsed Genre Info
                        HStack{
                            let cols = Int(storeCollapsedData.count / 3 + min(storeCollapsedData.count % 3, 1))
                            ForEach(0..<cols, id:\.self) { chunkIndex in
                                // Iterate through top genres in chunks of 3, adjust to fewer than 3 genres used
                                
                                VStack (alignment:.leading){
                                    // Iterate through elements in the current chunk
                                    let rows = min(3, storeCollapsedData.count - chunkIndex * 3)
                                    
                                    ForEach(0..<rows, id:\.self) { index in
                                        let i = index+3*chunkIndex
                                        HStack(alignment:.center){
                                            ZStack{
                                                Circle().fill(smallDisplayColors[i]).frame(width:infoIconSize,height:infoIconSize)
                                                Text(String(storeCollapsedData[i].recordIDs.count)).foregroundStyle(iconWhite)
                                            }
                                            Text(storeCollapsedData[i].name).foregroundStyle(recordBlack)
                                        }
                                    }
                                }.padding().frame(width:infoRowWidth,height:geometry.size.height)
                            }
                        }
                        .id(1)
                        .animation(.easeInOut(duration:0.5),value: true)
                        .transition(AsymmetricTransition(insertion:.move(edge:.trailing), removal: .move(edge:.leading)))
                }else{
                    GeometryReader{geometry in
                        ZStack(alignment:.center){
                            Map() {
                                ForEach(statsViewModel.topStores.indices, id: \.self) { index in
                                    let store = statsViewModel.topStores[index]
                                    if let loc = store.location{
                                        Annotation(coordinate: loc) {
                                            ZStack{
                                                Circle().fill(fullDisplayColors[index%totalDisplayColors])
                                                Text("\(store.recordIDs.count)").foregroundStyle(iconWhite).padding()
                                            }.onTapGesture{
                                                tapped = store.name
                                                infoExpanded = true
                                                infoColor = fullDisplayColors[index%totalDisplayColors]
                                            }
                                        } label: {
                                            Text(store.name)
                                        }
                                    }
                                }
                            }
                            if infoExpanded{
                                ZStack(alignment:.topLeading){
                                    LocationInfoView(statsViewModel:statsViewModel,spotifyController:spotifyController,genreManager:genreManager,storeName:tapped,color:infoColor)
                                    Button(action:{infoExpanded.toggle()}){
                                        Image(systemName: "xmark").padding()
                                    }
                                }.padding().frame(width: geometry.size.width, height: 3*geometry.size.height/4)
                            }
                        }
                    }.padding(30)
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
}

// Individual location details
struct LocationInfoView: View{
    @ObservedObject var statsViewModel: StatsViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    let storeName: String
    let color: Color
    
    let grid: Int = 3
    let size: Int = 70
    
    var body: some View{
        let store = statsViewModel.topStores.first(where: { $0.name == storeName})!
        var records: [RecordItem] {
            var output: [RecordItem] = []
            for recordID in store.recordIDs{
                if let record = statsViewModel.viewModel.recordDictionaryByID[recordID]{
                    output.append(record)
                }
            }
            // Sort the output array based on the RecordItem.dateAdded variable
            output.sort { (record1, record2) -> Bool in
                let date1 = String.stringToDate(from: record1.dateAdded)
                let date2 = String.stringToDate(from: record2.dateAdded)
                
                // Ensure that both dates are not nil before comparing
                guard let validDate1 = date1, let validDate2 = date2 else {
                    return false
                }

                return validDate1 > validDate2
            }

            return output
        }
        
        GeometryReader{geometry in
            ZStack{
                VStack{
                Text(store.name).smallHeadlineText()
                    ScrollView{
                        VStack{
                            let rows = records.count / 3 + (records.count % 3 == 0 ? 0 : 1)
                            ForEach(0..<rows, id:\.self) { row in
                                HStack {
                                    let cols = min(3, records.count - row * 3)
                                    ForEach(0..<cols,id:\.self) { column in
                                        let record = records[row * 3 + column]
                                        CoverPhotoToPopupView(viewModel: statsViewModel.viewModel, spotifyController: spotifyController, genreManager:genreManager, record: record,size:70)
                                    }
                                    ForEach(0..<(3-cols), id: \.self) { _ in
                                        Rectangle().fill(Color.clear).frame(width:70,height:70)
                                    }
                                }
                            }
                        }.padding(10)
                    }.background(color.opacity(0.3))
                }.padding()
            }.frame(width:geometry.size.width, height: geometry.size.height).background(iconWhite).clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)).shadow(radius: 5)
        }
        
//        GeometryReader{geometry in
//            ZStack{
//                ScrollView(.horizontal){
//                    HStack{
//                        ForEach(storeInfo.recordIDs, id:\.self){recordID in
//                            if let record = statsViewModel.viewModel.recordDictionaryByID[recordID]{
//                                CoverPhotoToPopupView(viewModel: statsViewModel.viewModel, spotifyController: spotifyController, genreManager:genreManager, record: record,size:50)
//                            }
//                        }
//                    }.padding()
//                }.background(recordBlack).padding().padding(.top,30)
//            }.frame(width:geometry.size.width, height: geometry.size.height).background(iconWhite).clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)).shadow(radius: 5)
//        }
    }
}

