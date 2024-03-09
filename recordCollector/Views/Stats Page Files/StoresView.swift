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

// Sidebar menu with all stores, camera panning, and window toggling
struct StoresMenuView: View{
    @ObservedObject var viewModel: LibraryViewModel
    @Binding var isMenuExpanded: Bool
    @Binding var camera: MapCameraPosition
    @Binding var infoExpanded: Bool
    @Binding var tapped: String
    
    let radius: CGFloat = 10.0
    
    var body: some View{
        GeometryReader{geometry in
            HStack(spacing:-2*radius){
                Spacer()
                ZStack(alignment:.leading){
                    RoundedRectangle(cornerRadius: radius).foregroundStyle(decorWhite).shadow(radius: 3)
                    Button{
                        isMenuExpanded.toggle()
                    }label:{
                        Image(systemName: isMenuExpanded ? "chevron.compact.right" :  "chevron.compact.left").resizable().frame(width:8).aspectRatio(contentMode:.fit).foregroundStyle(decorBlack).padding(5)
                    }
                }.frame(width:33,height:60)
                ZStack(){
                    ZStack{
                        RoundedRectangle(cornerRadius: radius).foregroundStyle(decorWhite).shadow(radius: 3)
//                        if isMenuExpanded{
                            ScrollView{
                                VStack(alignment:.leading){
                                    ForEach(viewModel.storeViewModel.topStores.indices, id: \.self) { index in
                                        HStack{
                                            let store = viewModel.storeViewModel.topStores[index]
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
                                                        Text(store.id).foregroundStyle(recordBlack)
                                                    }
                                                }.frame(height:30)
                                            }else{
                                                HStack(alignment:.center){
                                                    ZStack{
                                                        Circle().fill(fullDisplayColors[index%totalDisplayColors])
                                                        Text(String(store.recordIDs.count)).foregroundStyle(iconWhite)
                                                    }
                                                    Text(store.id  + "º").foregroundStyle(recordBlack)
                                                    
                                                }.frame(height:30)
                                            }
                                            Spacer()
                                            Button{
                                                tapped = store.id
                                                infoExpanded.toggle()
                                            }label:{
                                                Image(systemName: "ellipsis")
                                            }.frame(width:15,height:15)
                                        }
                                    }
                                }
                            }.padding().padding(.trailing,radius)

//                        }
                    }.padding(.vertical,radius)
                }.frame(width: 3*geometry.size.width/4,height:geometry.size.height).offset(x:radius/2+1)
            }.offset(x:isMenuExpanded ? radius : 3*geometry.size.width/4 - 2*radius).clipped().animation(.easeInOut(duration:0.3),value:isMenuExpanded)
        }
    }
}

// Stores infographic and map view with windows and sidebar
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
                    let percentage = Double(viewModel.storeViewModel.usedTotal) / Double(viewModel.recordLibrary.count) * 100.0
                    return Int(percentage)
                }
                return 0
            }
            var onlinePercentage: Int{
                if viewModel.recordLibrary.count != 0{
                    let percentage = Double(viewModel.storeViewModel.onlineTotal) / Double(viewModel.recordLibrary.count) * 100.0
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
                                angle: .value("Used", viewModel.storeViewModel.usedTotal),
                                innerRadius: .ratio(0.5),
                                angularInset: 1.5
                            ).foregroundStyle(pinkRed)
                            SectorMark(
                                angle: .value("New", viewModel.recordLibrary.count - viewModel.storeViewModel.usedTotal),
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
                                angle: .value("Used", viewModel.storeViewModel.onlineTotal),
                                innerRadius: .ratio(0.5),
                                angularInset: 1.5
                            ).foregroundStyle(deepBlue)
                            SectorMark(
                                angle: .value("New", viewModel.recordLibrary.count - viewModel.storeViewModel.onlineTotal),
                                innerRadius: .ratio(0.5)
                            ).foregroundStyle(grayBlue)
                        }.padding(10).chartBackground { chartProxy in
                            GeometryReader { geometry in
                                VStack {
                                    Text("Online")
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                    Text("\(onlinePercentage)%")
                                        .font(.title2.bold())
                                        .foregroundColor(.primary)
                                }
                                .position(x: geometry.size.width/2, y: geometry.size.height/2)
                            }
                        }
                    }.padding(10).animation(.easeInOut(duration:0.5),value: true)
                        .transition(.move(edge:.leading))
                }else{
                    GeometryReader{geometry2 in
                        ZStack(alignment:.center){
                            MapView(viewModel: viewModel, camera: $camera, tapped: $tapped, infoExpanded: $infoExpanded, infoColor: $infoColor)
                            StoresMenuView(viewModel:viewModel,isMenuExpanded: $menuExpanded, camera: $camera,infoExpanded:$infoExpanded,tapped:$tapped)
                            if infoExpanded{
                                ZStack(alignment:.topLeading){
                                    LocationInfoView(viewModel:viewModel,spotifyController:spotifyController,genreManager:genreManager,infoExpanded:$infoExpanded, storeName:tapped,color:infoColor)
                                }.padding().frame(width: geometry2.size.width, height: 3*geometry2.size.height/4)
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

// Interactive Map of all Stores
struct MapView: View{
    @ObservedObject var viewModel: LibraryViewModel
    @Binding var camera: MapCameraPosition
    @Binding var tapped: String
    @Binding var infoExpanded: Bool
    @Binding var infoColor: Color
    
    var body: some View{
        Map(position: $camera) {
            ForEach(viewModel.storeViewModel.topStores.indices, id: \.self) { index in
                let store = viewModel.storeViewModel.topStores[index]
                if let loc = store.location{
                    Annotation(coordinate: loc) {
                        ZStack{
                            Circle().fill(fullDisplayColors[index%totalDisplayColors])
                            Text("\(store.recordIDs.count)").foregroundStyle(iconWhite).padding()
                        }.onTapGesture{
                            tapped = store.id
                            infoExpanded = true
                            infoColor = fullDisplayColors[index%totalDisplayColors]
                        }
                    } label: {
                        Text(store.id)
                    }
                }
            }
        }
    }
}

// Individual location details
struct LocationInfoView: View{
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    
    @Binding var infoExpanded: Bool
    
    @State private var displayAddressField: Bool = false
    @State private var address: String = ""
    
    let storeName: String
    let color: Color
    
    let grid: Int = 3
    let size: Int = 70
    
    var body: some View{
        let store = viewModel.storeViewModel.topStores.first(where: { $0.id == storeName})!
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
                    HStack{
                        Button(action:{infoExpanded.toggle()}){
                            Image(systemName: "xmark")
                        }.frame(width:15,height:15)
                        Spacer()
                        Text(store.id).smallHeadlineText()
                        Spacer()
                        Button(action:{
                            if displayAddressField{
                                viewModel.storeViewModel.changeStoreAddress(storeName: store.id, address: address)
                            }
                            displayAddressField.toggle()
                        }){
                            Image(systemName: displayAddressField ? "checkmark.circle.fill" :  "square.and.pencil")
                        }.frame(width:15,height:15)
                    }.padding(.horizontal,5)
                    if displayAddressField{
                        VStack{
                            TextEditor(text: $address)
                            .onAppear{
                                address = store.addressString
                            }
                        }.padding().background(color.opacity(0.3)).clipShape(RoundedRectangle(cornerRadius: 10))
                    }else{
                        ScrollView{
                            LazyVStack{
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
                        }.background(color.opacity(0.3)).clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }.padding()
            }.frame(width:geometry.size.width, height: geometry.size.height).background(iconWhite).clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)).shadow(radius: 5)
        }
    }
}

