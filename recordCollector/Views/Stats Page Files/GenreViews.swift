//
//  GenreViews.swift
//  test3
//
//  Created by Hannah Adams on 1/12/24.
//

import SwiftUI
import Charts

struct GenrePieChart: View {
    @ObservedObject var viewModel: StatsViewModel //
    var isTabExpanded: Bool
    @State private var rotation = 0.0
    
    var body: some View {
        let genrePieData = viewModel.genreTotalData.prefix(6)
        let genreTotalData = viewModel.genreTotalData

        GeometryReader { geometry in
            // Pie Chart
            ZStack{
                ZStack{
                    Circle().fill(iconWhite).shadow(color:recordBlack,radius: 3)
                    Circle().fill(recordBlack).padding(5)
                    Circle().fill(iconWhite).padding(10)
                    Chart{
                        ForEach(genrePieData.indices, id: \.self) { index in
                            SectorMark(
                                angle: .value("Count", genrePieData[index].amount),
                                innerRadius: .ratio(0.3)
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

struct GenreInfoChart: View {
    @ObservedObject var viewModel: StatsViewModel //
    var isTabExpanded: Bool
    
    var body: some View {
        let genrePieData = viewModel.genreTotalData.prefix(6)
        let genreTotalData = viewModel.genreTotalData
        
        GeometryReader { geometry in
            let infoRowWidth: CGFloat = geometry.size.width/2-10
            let infoIconSize: CGFloat = geometry.size.height/4
            
            VStack{
                if !isTabExpanded{
                    // Collapsed Genre Info
                    HStack{
                        ForEach(0..<(genrePieData.count / 3 + min(genrePieData.count % 3, 1))) { chunkIndex in
                            // Iterate through top genres in chunks of 3, adjust to fewer than 3 genres used
                            
                            VStack (alignment:.leading){
                                // Iterate through elements in the current chunk
                                ForEach(0..<min(3, genrePieData.count - chunkIndex * 3)) { index in
                                    HStack(alignment:.center){
                                        ZStack{
                                            Circle().fill(smallDisplayColors[index+3*chunkIndex]).frame(width:infoIconSize,height:infoIconSize)
                                            Text(String(genrePieData[index+3*chunkIndex].amount)).foregroundStyle(iconWhite)
                                        }
                                        Text(genrePieData[index+3*chunkIndex].name).foregroundStyle(recordBlack)
                                    }
                                }
                            }.padding().frame(width:infoRowWidth,height:geometry.size.height)
                        }
                    }
                    .id(1)
                    .animation(.easeInOut(duration:0.5))
                    .transition(AsymmetricTransition(insertion:.move(edge:.trailing), removal: .move(edge:.leading)))
                }else{
                    //Expanded Genre Info
                    ScrollView{
                        ForEach(genreTotalData.indices, id: \.self) {index in
                            GenreRowView(genreItem:genreTotalData[index],color:fullDisplayColors[index%totalDisplayColors])
                        }
                    }.padding(.vertical,30)
                        .id(2)
                        .animation(.easeInOut(duration:0.5))
                        .transition(AsymmetricTransition(insertion:.move(edge:.trailing), removal: .move(edge:.leading)))
                }
            }.frame(width:geometry.size.width,height:geometry.size.height).clipped()

        }
    }
}

struct GenreRowView: View {
    var genreItem: DistributionItem
    var color: Color
    
    var body: some View {
        HStack{
            Circle().foregroundColor(color).scaledToFit().padding()
            HStack {
                Text(genreItem.name).bold()
                Spacer()
                Text(String(genreItem.amount))
            }.padding(.all,10.0)
            Spacer()
        }.padding(.horizontal, 20.0).frame(height:75)
    }
}
