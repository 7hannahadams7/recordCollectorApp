//
//  GenreViews.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/12/24.
//

import SwiftUI
import Charts

// Distributed Pie Chart
struct GenrePieChart: View {
    @ObservedObject var viewModel: LibraryViewModel //
    var isTabExpanded: Bool
    @State private var rotation = 0.0
    
    var body: some View {
        let genrePieData = viewModel.statsViewModel.topGenres.prefix(6)

        GeometryReader { geometry in
            // Pie Chart
            ZStack{
                ZStack{
                    Circle().fill(iconWhite).shadow(color:recordBlack,radius: 3)
                    Circle().fill(recordBlack).padding(5)
                    Circle().fill(iconWhite).padding(10)
                    VStack{
                        Text("\(viewModel.recordLibrary.count)").largeHeadlineText()
                        Text("Records").subtitleText()
                    }.opacity(isTabExpanded ? 0.0 : 1.0)
                    Chart{
                        ForEach(genrePieData.indices, id: \.self) { index in
                            SectorMark(
                                angle: .value("Count", genrePieData[index].amount),
                                innerRadius: .ratio(0.4)
                            ).foregroundStyle(smallDisplayColors[index])
                        }
                    }.padding(10)
                        .rotation3DEffect(.degrees(Double(rotation)), axis: (x: 0, y: 0, z:1 ))
                }.padding(10).aspectRatio(contentMode: .fit)
                
                // Record Arm Image
                Image("recordArmCropped").resizable().padding(5).aspectRatio(contentMode: .fit).shadow(color:recordBlack,radius: 3)
            }.frame(width:geometry.size.width,height:geometry.size.height)
                .onChange(of: isTabExpanded, initial: false) { value, value2 in
                    if value{
                        withAnimation(.easeOut(duration: 1.5).delay(0.2)){
                            rotation = 0.0
                        }completion: {
                            rotation = 0.0
                        }
                    }else{
                        withAnimation(.easeOut(duration: 0.2).delay(0.2)){
                            rotation = -30
                        }
                    }
                }
                .onAppear(perform: {
                    withAnimation(.easeOut(duration: 1.5)){
                        rotation = 360
                    }completion: {
                        rotation = 0.0
                    }
                })
            }
        }
}

// Genre Information in bottom tab, both expanded and collapsed
struct GenreInfoView: View {
    @ObservedObject var viewModel: LibraryViewModel //
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    @Binding var isTabExpanded: Bool
    
    @State private var offset = 0.0
    
    var body: some View {
        
        GeometryReader { geometry in
            let infoRowWidth: CGFloat = geometry.size.width/2-10
            let infoIconSize: CGFloat = geometry.size.height/4
            
            VStack{
                if !isTabExpanded{
                    // Collapsed Genre Info
                    HStack{
                        let count = min(6, viewModel.statsViewModel.topGenres.count)
                        let cols = Int(ceil(Double(count) / 3.0))

                        ForEach(0..<cols, id: \.self) { chunkIndex in
//                            // Iterate through top genres in chunks of 3, adjust to fewer than 3 genres used
//                            
                            VStack (alignment:.leading){
//                                // Iterate through elements in the current chunk
                                ForEach(0..<min(3, count - chunkIndex * 3), id: \.self) { index in
                                    let i = index + 3 * chunkIndex
                                    HStack(alignment:.center){
                                        ZStack{
                                            Circle().fill(smallDisplayColors[i]).frame(width:infoIconSize,height:infoIconSize)
                                            Text(String(viewModel.statsViewModel.topGenres[i].amount)).foregroundStyle(iconWhite)
                                        }
                                        Text(viewModel.statsViewModel.topGenres[i].name).foregroundStyle(recordBlack)
                                    }
                                }
                            }.padding().frame(width:infoRowWidth,height:geometry.size.height)
                        }


                    }
                    .id(1)
                    .animation(.easeInOut(duration:0.5),value: true)
                    .transition(AsymmetricTransition(insertion:.move(edge:.trailing), removal: .move(edge:.leading)))
                }else{
                    //Expanded Genre Info
                    ScrollView{
                        ForEach(viewModel.statsViewModel.topGenres.indices, id: \.self) {index in
                            GenreDetailRowView(genreItem:viewModel.statsViewModel.topGenres[index],viewModel:viewModel,spotifyController:spotifyController, genreManager: genreManager,  color:fullDisplayColors[index%totalDisplayColors])
                        }
                    }.padding(.vertical,30)
                        .id(2)
//                        .animation(.easeInOut(duration:0.5))
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
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

// Individual genre row with interactions, in InfoView when expanded
struct GenreDetailRowView: View {
    var genreItem: StatsNameItem
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    
    var color: Color
    
    @State private var expanded: Bool = false
    
    var body: some View {
        ZStack(alignment:.top){
            VStack{
                Spacer()
                ScrollView(.horizontal){
                    LazyHStack{
                        ForEach(genreItem.records, id:\.self){recordID in
                            if let record = viewModel.recordDictionaryByID[recordID]{
                                CoverPhotoToPopupView(viewModel: viewModel, spotifyController: spotifyController, genreManager:genreManager, record: record,size:50)
                            }
                        }
                    }
                }.frame(height:60).padding(.all,5).padding(.horizontal,20).background(Rectangle().fill(color).opacity(0.3))
            }.frame(height:expanded ? 150:70)
            HStack{
                Button(action:{
                    withAnimation(.easeInOut(duration: 0.5)) {
                        expanded.toggle()
                    }
                }){
                    Circle().foregroundColor(color).scaledToFit().padding()
                    HStack {
                        Text(genreItem.name).bold()
                        Spacer()
                        Text(String(genreItem.amount))
                    }.padding(.all,10.0)
                }
                Spacer()
            }.padding(.horizontal, 20.0).frame(height:75).background(decorWhite)
        }.padding(.trailing, 20.0).frame(height:expanded ? 150:75)
    }
}
