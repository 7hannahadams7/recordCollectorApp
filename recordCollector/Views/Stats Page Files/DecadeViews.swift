//
//  GenreViews.swift
//  test3
//
//  Created by Hannah Adams on 1/12/24.
//

import SwiftUI
import Charts

struct DecadeTopGraphic: View {
    @ObservedObject var viewModel: StatsViewModel
    var isTabExpanded: Bool
    @State private var offset = 0.0
    
    var images: [Image] = []
    
    var body: some View {
        let decadeBarData = viewModel.topDecades.prefix(4)
        
        var images: [Image] {
            var imageArray: [Image] = []

            for index in 0..<6 {
                let image: Image

                if index < decadeBarData.count {
                    let recordID = decadeBarData[index].records.first
                    let photo = viewModel.viewModel.fetchPhotoByID(id: recordID!)
                    if photo != UIImage(named:"TakePhoto"){
                        image = Image(uiImage: photo!)
                    }else{
                        image = Image("DavidBowie")
                    }
                } else {
                    image = Image("DavidBowie")
                }

                imageArray.append(image)
            }

            return imageArray
        }
        
        GeometryReader { geometry in
            let recordStack: CGFloat = geometry.size.height*0.85
            let recordSpacing: CGFloat = min(recordStack/3,(geometry.size.width-3*recordStack)/3)
            ZStack{
                ZStack(alignment:.bottom){
                        HStack(spacing:recordSpacing){
                            images[0].resizable().frame(width:recordStack, height:recordStack).scaledToFill().clipped()
                            images[1].resizable().frame(width:recordStack, height:recordStack).scaledToFill().clipped()
                            images[2].resizable().frame(width:recordStack, height:recordStack).scaledToFill().clipped()
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

struct DecadeBottomChart: View{
    @ObservedObject var viewModel: StatsViewModel //
    var isTabExpanded: Bool
    @State private var selectedTab = 1
    @State private var selectedBar: Int?

    @State private var offset = 0.0
    @State private var tapped = 0
    @State private var infoExpanded = false
        
        var body: some View {
            let decadeBarData = viewModel.topDecades.prefix(4)
            let decadeSortedData = viewModel.topDecades.sorted(by: { $0.decade > $1.decade })
            GeometryReader{geometry in
                VStack{
                    if !isTabExpanded{
                        HStack{

                            HStack{
                                let total = decadeBarData.count
                                let minAmount = decadeBarData.map { $0.amount }.min() ?? 1
                                let maxAmount = decadeBarData.map { $0.amount }.max() ?? 1
                                ForEach(decadeBarData.indices, id:\.self){index in
                                    let item = decadeBarData[index]
                                    DecadeBarItem(decade: item.decade, amount: item.amount, color: smallDisplayColors[index], total: total, minAmount: minAmount, maxAmount: maxAmount)
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
                                            BubbleView(decadeItem:decadeSortedData[index],color:fullDisplayColors[index%totalDisplayColors],index: index,prevAmount: (index != 0) ? decadeSortedData[index-1].amount : minAmount, minAmount: minAmount, maxAmount: maxAmount, width: geometry.size.width, tapped: $tapped, infoExpanded: $infoExpanded)
                                        }
                                    }.padding()
                                }
                                
                                if infoExpanded{
                                    ZStack(alignment:.topLeading){
                                        BubbleInfo(viewModel:viewModel,decade:tapped)
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

struct BubbleInfo: View{
    var viewModel: StatsViewModel
    let decade: Int
    
    var body: some View{
        let yearsInDecade = viewModel.fetchYearsByDecade(decade: decade)
        let yearlyData = viewModel.topYears
        GeometryReader{geometry in
            ZStack{
                ScrollView{
                    VStack{
                        ForEach(yearsInDecade.indices, id:\.self){index in
                            VStack(alignment:.leading){
                                Text(String(yearsInDecade[index].0))
                                ScrollView(.horizontal){
                                    HStack{
                                        ForEach(yearsInDecade[index].2, id:\.self){record in
                                            let photo = viewModel.viewModel.fetchPhotoByID(id: record)
                                            // BUTTON WITH NAVIGATION HERE
                                            Image(uiImage: photo!).resizable().frame(width:50, height:50).scaledToFill().clipped()
                                        }
                                    }.padding()
                                }.background(fullDisplayColors[index%totalDisplayColors].opacity(0.3))
                            }
                        }
                    }
                }.padding().padding(.top,30)
            }.frame(width:geometry.size.width, height: geometry.size.height).background(iconWhite).clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)).shadow(radius: 5)
        }
    }
}

struct BubbleView: View {
    let decadeItem: (decade: Int, amount: Int, records: [String])
    var color: Color
    var index: Int
    var prevAmount: Int
    var minAmount: Int
    var maxAmount: Int
    var width: CGFloat
    @Binding var tapped: Int
    @Binding var infoExpanded: Bool

    var body: some View {
        let decade = decadeItem.decade
        let amount = decadeItem.amount
        
        let radius = CGFloat(amount - minAmount + 1) / CGFloat(maxAmount - minAmount + 1) * (width/6) + 50
        let shift = width/2 - radius - 10
        let offset = (index%2 == 0) ? shift : -1 * shift

        let height = 2 * radius - 15 * (CGFloat(maxAmount/amount)-1)
        
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
                print("Tapped \(decadeItem.decade%100)s")
            }
    }
    
}

//struct BubbleTestView: View {
//    @State private var switching = false
//    let decadesData: [(decade: Int, amount: Int, records:[String])] = [(2000, 6,["ID1","ID2","ID3"]),(2010, 4,["ID1","ID2","ID3"]),(1990, 1,["ID1","ID2","ID3"]),(1950, 2,["ID1","ID2","ID3"])].sorted(by: { $0.decade > $1.decade })
//    
//    var body: some View {
//        GeometryReader{geometry in
//            ScrollView {
//                LazyVStack(spacing:0) {
//                    let minAmount = decadesData.map { $0.amount }.min() ?? 1
//                    let maxAmount = decadesData.map { $0.amount }.max() ?? 1
//                    ForEach(decadesData.indices, id: \.self) { index in
//                        BubbleView(decadeItem:decadesData[index],color:fullDisplayColors[index%totalDisplayColors],index: index,prevAmount: (index != 0) ? decadesData[index-1].amount : minAmount, minAmount: minAmount, maxAmount: maxAmount, width: geometry.size.width)
//                    }
//                }
//                .padding()
//            }
//        }
//    }
//
//}

//struct DecadeBottomChart2: View {
//    @ObservedObject var viewModel: StatsViewModel //
//    var isTabExpanded: Bool
//    @State private var selectedTab = 1
//    @State private var selectedBar: Int?
//    
//    @State private var offset = 0.0
//    
//    var body: some View {
//        let decadeBarData = viewModel.topDecades.prefix(4)
//
//        GeometryReader{geometry in
//            VStack{
//                if !isTabExpanded{
//                    ZStack{
//                        HStack{
//                            let total = decadeBarData.count
//                            let minAmount = decadeBarData.map { $0.amount }.min() ?? 1
//                            let maxAmount = decadeBarData.map { $0.amount }.max() ?? 1
//                            ForEach(decadeBarData.indices, id:\.self){index in
//                                let item = decadeBarData[index]
//                                DecadeBarItem(decade: item.decade, amount: item.amount, color: smallDisplayColors[index], total: total, minAmount: minAmount, maxAmount: maxAmount)
//                            }
//                        }
//                    }.padding().frame(width:geometry.size.width,height:geometry.size.height)
//                        .background(isTabExpanded ? Color.clear: decorWhite)
//                        .id(1)
//                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .leading)))
//                        .animation(.easeInOut(duration:0.5),value:isTabExpanded)
//                }else{
//                    VStack(alignment:.center){
//                        Picker("", selection: $selectedTab) {
//                            Text("Decades").tag(1)
//                            Text("Years").tag(2)
//                        }
//                        .pickerStyle(SegmentedPickerStyle())
//                        .padding().frame(width:geometry.size.width/2)
//                        ZStack{
//                            if selectedTab == 1{
//                                DecadeScrollView(viewModel: viewModel)
//                            }else{
//                                YearScrollView(viewModel: viewModel)
//                            }
//                        }.padding()
//                    }.padding()
//                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .top)))
//                        .animation(.easeInOut(duration:0.5),value:isTabExpanded)
//                }
//            }.frame(width:geometry.size.width,height:geometry.size.height).clipped()
//                .offset(x:offset)
//                .onAppear(perform: {
//                    offset = -screenWidth
//                    withAnimation(.easeOut(duration: 0.5).delay(0.4)){
//                        offset = 0.0
//                    }
//                })
//        }
//    }
//}
//
//struct YearScrollView: View{
//    var viewModel: StatsViewModel
//    
//    var body: some View{
//            let decadeBarData = viewModel.topYears.sorted { $0.0
//                < $1.0 }
//            VStack{
//                GeometryReader{geometry in
//                    
//                ScrollView(.horizontal){
//                    
//                        HStack{
//                            let minAmount = decadeBarData.map { $0.amount }.min() ?? 1
//                            let maxAmount = decadeBarData.map { $0.amount }.max() ?? 1
//                            ForEach(decadeBarData.indices, id:\.self){index in
//                                let item = decadeBarData[index]
//                                let proportionalSize = CGFloat(item.amount - minAmount + 1) / CGFloat(maxAmount - minAmount + 1) * (geometry.size.height - 100)+50
//                                ZStack(alignment:.bottom){
//                                    VStack{
//                                        Spacer()
//                                        
//                                        VStack{
//                                            Text(String(item.amount))
//                                                RoundedRectangle(cornerRadius: 25.0).fill(fullDisplayColors[index%totalDisplayColors])
//                                        }.frame(width:80,height:proportionalSize).padding(5)
//                                        
//                                    }
//                                    VStack{
//                                        Text(String(item.year)).bold().padding()
//                                    }.frame(width:80,height:30).background(iconWhite)
//                                }
//                                
//                            }
//                        }
//                    }
//                }.clipped()
//            }.padding(.horizontal).background(iconWhite)
//    }
//}
//
//struct DecadeScrollView: View{
//    var viewModel: StatsViewModel
//    
//    var body: some View{
//        let decadeBarData = viewModel.topDecades.sorted { $0.0
//                < $1.0 }
//        let minAmount = decadeBarData.map { $0.amount }.min() ?? 1
//        let maxAmount = decadeBarData.map { $0.amount }.max() ?? 1
//        VStack{
//            GeometryReader{geometry in
//                    
//                ScrollView(.horizontal){
//                        
//                    HStack{
//                        ForEach(decadeBarData.indices, id:\.self){index in
//                            let item = decadeBarData[index]
//                            let proportionalSize = CGFloat(item.amount - minAmount + 1) / CGFloat(maxAmount - minAmount + 1) * (geometry.size.height - 100)+50
//                            ZStack(alignment:.bottom){
//                                VStack{
//                                    Spacer()
//                                    
//                                    VStack{
//                                        Text(String(item.amount))
//                                        RoundedRectangle(cornerRadius: 25.0).fill(fullDisplayColors[index%totalDisplayColors])
//                                    }.frame(width:80,height:proportionalSize).padding(5)
//                                    
//                                }
//                                VStack{
//                                    Text(String(item.decade)).bold().padding()
//                                }.frame(width:80,height:30).background(iconWhite)
//                            }
//                            
//                        }
//                    }
//                }
//            }.clipped()
//        }.padding(.horizontal).background(iconWhite)
//    }
//}

struct DecadeBarItem: View{
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
