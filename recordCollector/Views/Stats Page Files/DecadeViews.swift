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
        let decadeTotalData = viewModel.decadeData
        let decadeTopData = viewModel.decadeTotalData.prefix(6)
        let yearlyData = viewModel.yearlyTotalData

        GeometryReader{geometry in
            if !isTabExpanded{
                ZStack{
                    Chart{
                        ForEach(decadeTopData.indices, id:\.self){
                            index in
                            let amount = decadeTopData[index].amount
                            let name = decadeTopData[index].name
                            BarMark(
                                x: .value("Year", name),
                                y: .value("Amount", amount)
                            )
                            .cornerRadius(5)
                            .foregroundStyle(smallDisplayColors[index])
                            .annotation(position: .top, alignment:.center) {
                                Text(name).foregroundStyle(recordBlack).padding(5)
                            }
                            .annotation(position: .overlay, alignment: .top) {
                                Text(String(amount)).foregroundStyle(iconWhite).padding(5)
                                
                            }
                        }
                        
                    }
                    .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        .chartYScale(domain:[0,decadeTopData[0].amount])
                        .padding(.horizontal,15).padding(.top,35)
                        .frame(width:geometry.size.width,height:geometry.size.height)
                        .aspectRatio(contentMode: .fit)
                    
                }.frame(width:geometry.size.width,height:geometry.size.height)
            }else{
                VStack(alignment:.center){
                    Picker("", selection: $selectedTab) {
                        Text("Decades").tag(1)
                        Text("Years").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding().frame(width:geometry.size.width/2)
                    ZStack{
                        if selectedTab == 1 {
                            Chart{
                                ForEach(decadeTotalData.sorted(by: >), id: \.key){
                                    decade, amount in
                                    let index = decade/10%totalDisplayColors
                                    let displayToggle: Bool = (index<=5)
                                    BarMark(
                                        x: .value("Year", decade+5),
                                        y: .value("Amount", amount),
                                        width:MarkDimension(floatLiteral: geometry.size.width/6)
                                    )
                                    .cornerRadius(5)
                                    .foregroundStyle(fullDisplayColors[index])
                                    .annotation(position: .overlay, alignment:.top){
                                        Text(String(decade)).foregroundStyle(displayToggle ? iconWhite: recordBlack)
                                    }.annotation(position: .top, alignment:.center){
                                        Text(String(amount)).foregroundStyle(recordBlack)
                                    }
                                }
                            }
                            .chartScrollableAxes(.horizontal)
                                .chartXScale(domain:[1860,2030])
                                .chartYScale(domain:[0,30])
                                .chartXVisibleDomain(length: 40)
                                .aspectRatio(contentMode: .fit)
                                .frame(width:geometry.size.width,height:2*geometry.size.height/3)
                        } else if selectedTab == 2 {
                            Chart{
                                ForEach(yearlyData.sorted(by: >), id: \.key){
                                    year, amount in
                                    let index = year%totalDisplayColors
                                    BarMark(
                                        x: .value("Year", year),
                                        y: .value("Amount", amount),
                                        width:MarkDimension(floatLiteral: geometry.size.width/10)
                                    )
                                    .cornerRadius(5)
                                    .foregroundStyle(fullDisplayColors[index])
//                                    if let selectedBar{
//                                        RuleMark(x: .value("Year",selectedBar))
//                                            .foregroundStyle(grayBlue).zIndex(-10)
//                                    }
                                }
                            }
//                            .chartXSelection(value: $selectedBar)
                            .chartScrollableAxes(.horizontal)
                                .chartXScale(domain:[1969,2025])
                                .chartYScale(domain:[0,10])
                                .chartXVisibleDomain(length: 5)
                                .aspectRatio(contentMode: .fit)
                                .frame(width:geometry.size.width,height:2*geometry.size.height/3)
                        }
                    }.aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                }.frame(width:geometry.size.width,height:geometry.size.height)
            }
        }
    }
}
