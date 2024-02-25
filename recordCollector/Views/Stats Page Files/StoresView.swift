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
    @ObservedObject var viewModel: StatsViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    @Binding var isTabExpanded: Bool
    @State private var offset = 0.0

    
    var body: some View {
        let storeCollapsedData = viewModel.topStores.prefix(6)
        
        GeometryReader { geometry in
            let infoRowWidth: CGFloat = geometry.size.width/2-10
            let infoIconSize: CGFloat = geometry.size.height/4
            // Table Graphic
            VStack{
                if !isTabExpanded{
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
                    }
                }else{
                    Map() {
                        ForEach(viewModel.topStores.indices, id: \.self) { index in
                            let store = viewModel.topStores[index]
                            if let loc = store.location{
                                Marker(store.name,monogram:Text("\(store.recordIDs.count)"), coordinate:loc)
                                    .tint(fullDisplayColors[index%totalDisplayColors])
                            }
                        }
                    }
                }
                
            }.frame(width:geometry.size.width,height:geometry.size.height).clipped()
                .offset(x:offset)
                .onAppear(perform: {
                    offset = -screenWidth
                    withAnimation(.easeOut(duration: 0.5).delay(0.4)){
                        offset = 0.0
                    }
                    print("HERE: ",viewModel.topStores)
                })
        }

    }
}
