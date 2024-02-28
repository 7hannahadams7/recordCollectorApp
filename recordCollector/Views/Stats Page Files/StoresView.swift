//
//  StoresView.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/25/24.
//

import Foundation
import SwiftUI
import MapKit
import Charts

struct StoresInfoView_Previews: PreviewProvider {
    static var previews: some View {
        StoresInfoView(viewModel:testViewModel,spotifyController:SpotifyController(), genreManager:GenreManager(), isTabExpanded: .constant(false)).onAppear{testViewModel.refreshData()}.frame(width:350,height:350)
    }
}

struct StoresMenuView: View{
    @ObservedObject var viewModel: LibraryViewModel
    @Binding var isMenuExpanded: Bool
    @Binding var camera: MapCameraPosition
    
    let radius: CGFloat = 10.0
    
    var body: some View{
        GeometryReader{geometry in
            HStack(spacing:-2*radius){
                Spacer()
                ZStack(alignment:.leading){
                    RoundedRectangle(cornerRadius: radius).foregroundStyle(lightWoodBrown).shadow(radius: 3)
                    Button{
                        isMenuExpanded.toggle()
                    }label:{
                        Image(systemName: isMenuExpanded ? "chevron.compact.right" :  "chevron.compact.left").resizable().frame(width:8).aspectRatio(contentMode:.fit).foregroundStyle(woodAccent).padding(5)
                    }
                }.frame(width:30,height:60)
                ZStack{
                    RoundedRectangle(cornerRadius: radius).foregroundStyle(lightWoodBrown).shadow(radius: 3)
                    if isMenuExpanded{
                        ScrollView{
                            VStack(alignment:.leading){
                                ForEach(viewModel.statsViewModel.topStores.indices, id: \.self) { index in
                                    let store = viewModel.statsViewModel.topStores[index]
                                    if let loc = store.location{
                                        Button{
                                            camera = .region(MKCoordinateRegion(center: loc, latitudinalMeters: 600, longitudinalMeters: 600))
                                            isMenuExpanded.toggle()
                                        }label:{
                                            HStack(alignment:.center){
                                                ZStack{
                                                    Circle().fill(fullDisplayColors[index%totalDisplayColors])
                                                    Text(String(store.recordIDs.count)).foregroundStyle(iconWhite)
                                                }
                                                Text(store.name).foregroundStyle(recordBlack)
                                            }
                                        }.frame(height:30)
                                    }
                                }
                            }
                        }.padding()
                    }
                }.frame(width: isMenuExpanded ? 3*geometry.size.width/4 : 15,height:geometry.size.height).offset(x:radius/2+1)
            }.clipped()
        }
    }
}

struct StoresInfoView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    @Binding var isTabExpanded: Bool
    @State private var offset = 0.0

    @State private var tapped: String = ""
    @State private var infoExpanded = false
    @State private var infoColor: Color = seaweedGreen
    @State private var menuExpanded = false
    
    @State var camera: MapCameraPosition = .automatic
    
    var body: some View {
        
        GeometryReader { geometry in

            var usedPercentage: Int{
                if viewModel.recordLibrary.count != 0{
                    let percentage = Double(viewModel.statsViewModel.usedTotal) / Double(viewModel.recordLibrary.count) * 100.0
                    return Int(percentage)
                }
                return 0
            }
            var onlinePercentage: Int{
                if viewModel.recordLibrary.count != 0{
                    let percentage = Double(viewModel.statsViewModel.onlineTotal) / Double(viewModel.recordLibrary.count) * 100.0
                    return Int(percentage)
                }
                return 0
            }
            // Table Graphic
            VStack{
                if !isTabExpanded{
                    HStack{
                        Chart{
                            SectorMark(
                                angle: .value("Used", viewModel.statsViewModel.usedTotal),
                                innerRadius: .ratio(0.5),
                                angularInset: 1.5
                            ).foregroundStyle(pinkRed)
                            SectorMark(
                                angle: .value("New", viewModel.recordLibrary.count - viewModel.statsViewModel.usedTotal),
                                innerRadius: .ratio(0.5)
                            ).foregroundStyle(paleRed)
                        }.padding(10).chartBackground { chartProxy in
                            GeometryReader { geometry in
                                let frame = geometry[chartProxy.plotFrame!]
                                VStack {
                                    Text("Used")
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                    Text("\(usedPercentage)%")
                                        .font(.title2.bold())
                                        .foregroundColor(.primary)
                                }
                                .position(x: frame.midX, y: frame.midY)
                            }
                        }
                        Chart{
                            SectorMark(
                                angle: .value("Used", viewModel.statsViewModel.onlineTotal),
                                innerRadius: .ratio(0.5),
                                angularInset: 1.5
                            ).foregroundStyle(deepBlue)
                            SectorMark(
                                angle: .value("New", viewModel.recordLibrary.count - viewModel.statsViewModel.onlineTotal),
                                innerRadius: .ratio(0.5)
                            ).foregroundStyle(grayBlue)
                        }.padding(10).chartBackground { chartProxy in
                            GeometryReader { geometry in
                                let frame = geometry[chartProxy.plotAreaFrame]
                                VStack {
                                    Text("Online")
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                    Text("\(onlinePercentage)%")
                                        .font(.title2.bold())
                                        .foregroundColor(.primary)
                                }
                                .position(x: frame.midX, y: frame.midY)
                            }
                        }
                    }.padding(10).animation(.easeInOut(duration:0.5),value: true)
                        .transition(.move(edge:.leading))
                }else{
                    GeometryReader{geometry in
                        ZStack(alignment:.center){
                            Map(position: $camera) {
                                ForEach(viewModel.statsViewModel.topStores.indices, id: \.self) { index in
                                    let store = viewModel.statsViewModel.topStores[index]
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
                            StoresMenuView(viewModel:viewModel,isMenuExpanded: $menuExpanded, camera: $camera)
                            if infoExpanded{
                                ZStack(alignment:.topLeading){
                                    LocationInfoView(viewModel:viewModel,spotifyController:spotifyController,genreManager:genreManager,storeName:tapped,color:infoColor)
                                    Button(action:{infoExpanded.toggle()}){
                                        Image(systemName: "xmark").padding()
                                    }
                                }.padding().frame(width: geometry.size.width, height: 3*geometry.size.height/4)
                            }
                        }.animation(.easeInOut(duration:0.5),value:isTabExpanded)
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
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    let storeName: String
    let color: Color
    
    let grid: Int = 3
    let size: Int = 70
    
    var body: some View{
        let store = viewModel.statsViewModel.topStores.first(where: { $0.name == storeName})!
        var records: [RecordItem] {
            var output: [RecordItem] = []
            for recordID in store.recordIDs{
                if let record = viewModel.recordDictionaryByID[recordID]{
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
                                        CoverPhotoToPopupView(viewModel: viewModel, spotifyController: spotifyController, genreManager:genreManager, record: record,size:70)
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
    }
}

