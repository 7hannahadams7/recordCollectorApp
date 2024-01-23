//
//  GenreViews.swift
//  test3
//
//  Created by Hannah Adams on 1/12/24.
//

import SwiftUI
import Charts

struct DecadeTopGraphic: View {
    @ObservedObject var viewModel: StatsViewModel //
    var isTabExpanded: Bool
    @State private var offset = 0.0
    
    var body: some View {
        
        GeometryReader { geometry in
            let recordStack: CGFloat = geometry.size.height*0.85
            let recordSpacing: CGFloat = min(recordStack/3,(geometry.size.width-3*recordStack)/3)
            ZStack{
                ZStack(alignment:.bottom){
                        HStack(spacing:recordSpacing){
                            Image("DavidBowie").resizable().aspectRatio(contentMode:.fit)
                            Image("PinkFloyd").resizable().aspectRatio(contentMode: .fit)
                            Image("TheSmiths").resizable().aspectRatio(contentMode: .fit)
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

struct DecadeBottomChart: View {
    @ObservedObject var viewModel: StatsViewModel //
    var isTabExpanded: Bool
    @State private var selectedTab = 1
    @State private var selectedBar: Int?
    
    var body: some View {
        let decadeBarData = viewModel.topDecades.prefix(4)

        GeometryReader{geometry in
            VStack{
                if !isTabExpanded{
                    ZStack{
                        HStack{
                            let total = decadeBarData.count
                            let minAmount = decadeBarData.map { $0.amount }.min() ?? 1
                            let maxAmount = decadeBarData.map { $0.amount }.max() ?? 1
                            ForEach(decadeBarData.indices, id:\.self){index in
                                let item = decadeBarData[index]
                                DecadeBarItem(decade: item.decade, amount: item.amount, color: smallDisplayColors[index], total: total, minAmount: minAmount, maxAmount: maxAmount)
                            }
                        }
                    }.padding().frame(width:geometry.size.width,height:geometry.size.height)
                        .background(isTabExpanded ? Color.clear: decorWhite)
                        .id(1)
                        .animation(.easeInOut(duration:0.5).delay(0.05))
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .leading)))
                }else{
                    VStack(alignment:.center){
                        Picker("", selection: $selectedTab) {
                            Text("Decades").tag(1)
                            Text("Years").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding().frame(width:geometry.size.width/2)
                        ZStack{
                            if selectedTab == 1{
                                DecadeScrollView(viewModel: viewModel)
                            }else{
                                YearScrollView(viewModel: viewModel)
                            }
                        }.padding()
                    }.padding()
                }
            }.frame(width:geometry.size.width,height:geometry.size.height).clipped()
        }
    }
}

struct YearScrollView: View{
    var viewModel: StatsViewModel
    
    var body: some View{
            let decadeBarData = viewModel.topYears.sorted { $0.0
                < $1.0 }
            VStack{
                GeometryReader{geometry in
                    
                ScrollView(.horizontal){
                    
                        HStack{
                            let minAmount = decadeBarData.map { $0.amount }.min() ?? 1
                            let maxAmount = decadeBarData.map { $0.amount }.max() ?? 1
                            ForEach(decadeBarData.indices, id:\.self){index in
                                let item = decadeBarData[index]
                                let proportionalSize = CGFloat(item.amount - minAmount + 1) / CGFloat(maxAmount - minAmount + 1) * (geometry.size.height - 100)+50
                                ZStack(alignment:.bottom){
                                    VStack{
                                        Spacer()
                                        
                                        VStack{
                                            Text(String(item.amount))
                                                RoundedRectangle(cornerRadius: 25.0).fill(fullDisplayColors[index%totalDisplayColors])
                                        }.frame(width:80,height:proportionalSize).padding(5)
                                        
                                    }
                                    VStack{
                                        Text(String(item.year)).bold().padding()
                                    }.frame(width:80,height:30).background(iconWhite)
                                }
                                
                            }
                        }
                    }
                }.clipped()
            }.padding(.horizontal).background(iconWhite)
    }
}

struct DecadeScrollView: View{
    var viewModel: StatsViewModel
    
    var body: some View{
        let decadeBarData = viewModel.topDecades.sorted { $0.0
                < $1.0 }
        let minAmount = decadeBarData.map { $0.amount }.min() ?? 1
        let maxAmount = decadeBarData.map { $0.amount }.max() ?? 1
        VStack{
            GeometryReader{geometry in
                    
                ScrollView(.horizontal){
                        
                    HStack{
                        ForEach(decadeBarData.indices, id:\.self){index in
                            let item = decadeBarData[index]
                            let proportionalSize = CGFloat(item.amount - minAmount + 1) / CGFloat(maxAmount - minAmount + 1) * (geometry.size.height - 100)+50
                            ZStack(alignment:.bottom){
                                VStack{
                                    Spacer()
                                    
                                    VStack{
                                        Text(String(item.amount))
                                        RoundedRectangle(cornerRadius: 25.0).fill(fullDisplayColors[index%totalDisplayColors])
                                    }.frame(width:80,height:proportionalSize).padding(5)
                                    
                                }
                                VStack{
                                    Text(String(item.decade)).bold().padding()
                                }.frame(width:80,height:30).background(iconWhite)
                            }
                            
                        }
                    }
                }
            }.clipped()
        }.padding(.horizontal).background(iconWhite)
    }
}

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
