//
//  DecadeViews.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/12/24.
//

import SwiftUI
import Charts

// Shelf of 3 artist instances from top decades, with interaction
struct DecadeTopGraphic: View {
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    @Binding var isTabExpanded: Bool
    @State private var offset = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            let recordStack: CGFloat = geometry.size.height*0.85
            let recordSpacing: CGFloat = min(recordStack/3,(geometry.size.width-3*recordStack)/3)
            
            let decadeBarData = viewModel.statsViewModel.topDecades.prefix(4)
        
            var popups: [CoverPhotoToPopupView] {
                var popupArray: [CoverPhotoToPopupView] = []

                for index in 0..<3 {
                    let popup: CoverPhotoToPopupView
                    var record = defaultRecordItems[index]
                    if index < decadeBarData.count {
                        let recordID = decadeBarData[index].records.first
                        record = viewModel.recordDictionaryByID[recordID!]!
                    }
                    popup = CoverPhotoToPopupView(viewModel: viewModel, spotifyController: spotifyController, genreManager: genreManager, record:record, size: recordStack)

                    popupArray.append(popup)
                }

                return popupArray
            }
            
            ZStack{
                ZStack(alignment:.bottom){
                        HStack(spacing:recordSpacing){
                            popups[0]
                            popups[1]
                            popups[2]
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

// Decade Information in bottom tab, both expanded and collapsed
struct DecadeBottomChart: View{
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    
    @Binding var isTabExpanded: Bool
    
    @State private var selectedTab = 1
    @State private var selectedBar: Int?

    @State private var offset = 0.0
    @State private var tapped = 0
    @State private var infoExpanded = false
        
        var body: some View {
            let decadeBarData = viewModel.statsViewModel.topDecades.prefix(4)
            let decadeSortedData = viewModel.statsViewModel.topDecades.sorted(by: { $0.value > $1.value })
            GeometryReader{geometry in
                VStack{
                    if !isTabExpanded{
                        HStack{

                            HStack{
                                let total = min(4,viewModel.statsViewModel.topDecades.count)
                                let minAmount = Array(viewModel.statsViewModel.topDecades.prefix(4)).map { $0.amount }.min() ?? 1
                                let maxAmount = Array(viewModel.statsViewModel.topDecades.prefix(4)).map { $0.amount }.max() ?? 1
                                ForEach(Array(viewModel.statsViewModel.topDecades.prefix(4)).indices, id:\.self){index in
//                                    let item = decadeBarData[index]
                                    DecadeCollapsedBarView(decade: viewModel.statsViewModel.topDecades[index].value, amount: viewModel.statsViewModel.topDecades[index].amount, color: smallDisplayColors[index], total: total, minAmount: minAmount, maxAmount: maxAmount)
                                }
                            }
//                            Spacer()
                        }.padding().frame(width:geometry.size.width,height:geometry.size.height)
                            .background(isTabExpanded ? Color.clear: decorWhite)
                            .id(1)
                            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .leading)))
                            .animation(.easeInOut(duration:0.5),value:isTabExpanded)
                    }else{
                        GeometryReader{geometry in
                            ZStack(alignment:.center){
                                ScrollView {
                                    LazyVStack(spacing:0) {
                                        let minAmount = decadeSortedData.map { $0.amount }.min() ?? 1
                                        let maxAmount = decadeSortedData.map { $0.amount }.max() ?? 1
                                        ForEach(decadeSortedData.indices, id: \.self) { index in
                                            DecadeBubbleView(decadeItem:decadeSortedData[index],color:fullDisplayColors[index%totalDisplayColors],index: index,prevAmount: (index != 0) ? decadeSortedData[index-1].amount : minAmount, minAmount: minAmount, maxAmount: maxAmount, width: geometry.size.width, tapped: $tapped, infoExpanded: $infoExpanded)
                                        }
                                    }.padding(.top,30)
                                }
                                
                                if infoExpanded{
                                    ZStack(alignment:.topLeading){
                                        DecadeBubbleInfoView(viewModel:viewModel,spotifyController:spotifyController,genreManager:genreManager,decade:tapped)
                                        Button(action:{infoExpanded.toggle()}){
                                            Image(systemName: "xmark").padding()
                                        }
                                    }.padding().frame(width: geometry.size.width, height: 3*geometry.size.height/4)
                                }
                            }
                            }.padding(30)
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .top)))
                                .animation(.easeInOut(duration:0.5),value:isTabExpanded)
                        
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

// Decade bubbles, sizes and offsets adjust to create flowing display, in InfoView when expanded
struct DecadeBubbleView: View {
//    let decadeItem: (decade: Int, amount: Int, records: [String])
    let decadeItem: StatsValueItem
    var color: Color
    var index: Int
    var prevAmount: Int
    var minAmount: Int
    var maxAmount: Int
    var width: CGFloat
    @Binding var tapped: Int
    @Binding var infoExpanded: Bool

    var body: some View {
        let decade = decadeItem.value
        let amount = decadeItem.amount
        
        let radius = CGFloat(amount - minAmount + 1) / CGFloat(maxAmount - minAmount + 1) * (width/6) + 50
        let shift = width/2 - radius - 10
        let offset = (index%2 == 0) ? shift : -1 * shift

        let height = 3*radius/2 + radius * CGFloat(amount/maxAmount)
        
        ZStack {
            Circle()
                .foregroundColor(color) // Customize the color as needed
                .frame(width: 2*radius, height: 2*radius)
            let decadeTitle = (decade%100 != 0) ? "\(decade%100)s" : "0\(decade%100)s"
            VStack{
                Text("\(decadeTitle)")
                    .foregroundColor(iconWhite)
                    .font(.system(size: radius/2))
                Text("\(amount)").foregroundColor(iconWhite)
                    .font(.system(size: 25))
            }
        }.frame(width: width, height: height).offset(x: offset)
            .onTapGesture {
                tapped = decade
                infoExpanded = true
            }
    }
    
}

// Individual decade details, lists years in decade with interactive record instances, in InfoView when expanded
struct DecadeBubbleInfoView: View{
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    let decade: Int
    
    var body: some View{
        let yearsInDecade = viewModel.statsViewModel.fetchYearsByDecade(decade: decade)
        GeometryReader{geometry in
            ZStack{
                ScrollView{
                    VStack{
                        ForEach(yearsInDecade.indices, id:\.self){index in
                            VStack(alignment:.leading){
                                Text(String(yearsInDecade[index].value))
                                ScrollView(.horizontal){
                                    HStack{
                                        ForEach(yearsInDecade[index].records, id:\.self){recordID in
                                            if let record = viewModel.recordDictionaryByID[recordID]{
                                                CoverPhotoToPopupView(viewModel: viewModel, spotifyController: spotifyController, genreManager:genreManager, record: record,size:50)
                                            }
                                        }
                                    }.padding()
                                }.background(fullDisplayColors[index%totalDisplayColors].opacity(0.3)).clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }.padding().padding(.top,30)
            }.frame(width:geometry.size.width, height: geometry.size.height).background(iconWhite).clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)).shadow(radius: 5)
        }
    }
}

// Individual decade bar for collapsed view
struct DecadeCollapsedBarView: View{
    var decade: Int
    var amount: Int
    var color: Color
    var total: Int
    var minAmount: Int
    var maxAmount: Int
    
    var body: some View{
        GeometryReader{geometry in

            let proportionalSize = CGFloat(amount - minAmount + 1) / CGFloat(maxAmount - minAmount + 1) * (geometry.size.height - 100)+100
            ZStack(alignment:.bottom){
                VStack{
                    Spacer()
                    VStack{
                        Text("\(amount)")
                        RoundedRectangle(cornerRadius: 25.0).fill(color).overlay(alignment: .top) {
                            Text("\(decade%100)s").bold().foregroundStyle(iconWhite).padding()
                        }

                    }.frame(width:geometry.size.width,height:proportionalSize)
                }.frame(height:geometry.size.height).background(decorWhite)
                VStack{
                    Spacer()
                }.frame(width:geometry.size.width,height:30).background(decorWhite)
            }.padding(.bottom,30)
        }.clipped()

    }
}
