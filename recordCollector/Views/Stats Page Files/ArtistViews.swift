//
//  GenreViews.swift
//  test3
//
//  Created by Hannah Adams on 1/12/24.
//

import SwiftUI
import Charts

struct ArtistRecordShelf: View {
    @ObservedObject var viewModel: StatsViewModel //
    var isTabExpanded: Bool
    @State private var offset = 0.0
    
    var body: some View {
        
        GeometryReader { geometry in
            let recordStack: CGFloat = geometry.size.height/2*0.85
            let recordSpacing: CGFloat = min(recordStack/3,(geometry.size.width-3*recordStack)/3)
            
            VStack{
                //Top Shelf
                ZStack(alignment:.bottom){
                    HStack(spacing:recordSpacing){
                        Image("DavidBowie").resizable().aspectRatio(contentMode:.fit)
                        Image("PinkFloyd").resizable().aspectRatio(contentMode: .fit)
                        Image("TheSmiths").resizable().aspectRatio(contentMode: .fit)
                    }.frame(height: recordStack)
                    Rectangle().frame(width:4*recordStack,height:0.15*recordStack).foregroundColor(lightWoodBrown).offset(y:3)
                    
                }.frame(height: recordStack).shadow(color:Color.black,radius:2)
                //Bottom Shelf
                ZStack(alignment:.bottom){
                    HStack(spacing:recordSpacing){
                        Image("LedZeppelin").resizable().aspectRatio(contentMode:.fit)
                        Image("Radiohead").resizable().aspectRatio(contentMode: .fit)
                        Image("S&G").resizable().aspectRatio(contentMode: .fit)
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


struct ArtistInfoChart: View {
    @ObservedObject var viewModel: StatsViewModel //
    var isTabExpanded: Bool
    @State private var offset = 0.0
    
    var body: some View {
        let artistBarData = viewModel.topArtists.prefix(6)
        let artistTotalData = viewModel.topArtists
        let totalArtists = artistTotalData.count
        
        GeometryReader { geometry in
                
            // Table Graphic
            VStack{
                if !isTabExpanded{
                    ZStack{
                        VStack{
                            ForEach(artistBarData.indices, id:\.self){index in
//                                Text(artistBarData[index].artist)
                                let item = artistBarData[index]
                                let center_val = artistBarData.last!.count - artistBarData[0].count
                                ArtistBarItem(artist: item.artist, count: item.count, color: smallDisplayColors[index%6], center: CGFloat(center_val), total: artistBarData.count)
//                                ArtistRowView(artistItem:artistBarData[index],viewModel:viewModel,color:smallDisplayColors[index%6],positionProportion:fractionalValue(for: index, totalCount: totalArtists)
//                                ).id(3).animation(.easeInOut(duration:0.3))
                            }
                        }
//                    Chart{
//                        ForEach(artistBarData.indices, id:\.self){
//                            index in
//                            let amount = artistBarData[index].count
//                            let name = artistBarData[index].artist
//                            BarMark(
//                                x: .value("Amount", amount),
//                                y: .value("Position", name)
//                            )
//                            .cornerRadius(5)
//                            .foregroundStyle(smallDisplayColors[index])
//                            .annotation(position: .trailing, alignment: .leading) {
//                                Text(String(amount)).foregroundStyle(recordBlack).padding(5)
//                            }
//                            .annotation(position: .overlay, alignment: .trailing) {
//                                Text(name).foregroundStyle(iconWhite).padding(5)
//                                
//                            }
//                        }
//                    }.chartXAxis(.hidden)
//                        .chartYAxis(.hidden)
//                        .chartScrollableAxes(isTabExpanded ? .vertical : [])
//                        .chartXScale(domain: [artistBarData.last!.count-1, artistBarData[0].count])
//                        .aspectRatio(contentMode: .fit)
//                        .padding(5)
                    }.frame(width:geometry.size.width,height:geometry.size.height)
                        .background(isTabExpanded ? Color.clear: decorWhite)
                        .id(1)
                        .animation(.easeInOut(duration:0.5).delay(0.05))
                        .transition( .move(edge: .leading))
                }else{
                    ScrollView{
                        ForEach(artistTotalData.indices, id:\.self){index in
                            ArtistRowView(artistItem:artistTotalData[index],viewModel:viewModel,color:fullDisplayColors[index%totalDisplayColors],positionProportion:fractionalValue(for: index, totalCount: totalArtists)
                            ).id(3).animation(.easeInOut(duration:0.3))
                            
                        }
                    }.padding(.vertical,30)
                        .id(2)
                        .animation(.easeInOut(duration:0.5).delay(0.15))
//                            Animation.default.delay(0.2))
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))

//                        .onChange(of: isTabExpanded, initial: false) { value, value2 in
//                            if value{
//                                withAnimation(.easeOut(duration: 0.5).delay(0.5)){
//                                    self.transition(.move(edge:.leading))
//                                }
//                            }
//                        }
                        
//                        .transition( .move(edge: .leading)).animation(.easeInOut(duration:1.0).delay(3.0),value:isTabExpanded)/*.frame(width:geometry.size.width,height:geometry.size.height).clipped()*/
                    
                }
                
            }.frame(width:geometry.size.width,height:geometry.size.height).clipped()
            
        }

    }
    
    private func fractionalValue(for index: Int, totalCount: Int) -> CGFloat {
        guard totalCount > 0 else {
            return 0.0
        }
        return CGFloat(totalCount - index) / CGFloat(totalCount)
    }
}

struct ArtistBarItem: View{
    var artist: String
    var count: Int
    var color: Color
    var center: CGFloat
    var total: Int
    
    var body: some View{
        let shift = CGFloat(count)-center*100
        GeometryReader{geometry in
            HStack{
                HStack{
                    RoundedRectangle(cornerRadius: 25.0).fill(color).overlay(alignment: .trailing) {
                        Text(artist).bold().foregroundStyle(iconWhite).padding()
                    }
                    Text(String(count))
                    Spacer()
                }.padding(5).frame(width:screenWidth*0.75+100*shift,height:geometry.size.height/(CGFloat(total))).offset(x:-30)
                Spacer()
            }.background(decorWhite)
        }
    }
}

struct ArtistRowView: View {
    var artistItem: (artist: String, count: Int, records: [String]);
    var viewModel: StatsViewModel
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
                            let recordItem: RecordItem = viewModel.viewModel.recordDictionaryByID[recordID]!
                            let photo = recordItem.photo
                            Image(uiImage: photo!).resizable().frame(width:50, height:50).scaledToFill().clipped()
                        }
                    }
                }.frame(height:60).padding(.all,5).padding(.horizontal,20).background(Rectangle().fill(color).opacity(0.3))
            }.frame(height:expanded ? 150:70)
            HStack{
                HStack{
                    ZStack{
                        RoundedRectangle(cornerRadius: 25.0).fill(color).overlay(alignment: .trailing) {
                            Text(artistItem.artist).bold().foregroundStyle(iconWhite).padding()
                        }
                    }
                    Button(action:{
                        expanded.toggle()
                    }){
                        Text(String(artistItem.count))
                    }.padding()
                    Spacer()
                }.padding(5).frame(width:screenWidth*0.75+100*positionProportion,height:75).offset(x:-30)
                Spacer()
            }.background(decorWhite)
        }.padding(.trailing, 20.0).frame(height:expanded ? 150:75)
    }
}

