//
//  HistoryViews.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/24/24.
//

import Foundation
import SwiftUI

// Displays all history items and allows sorting between. Can interact with record in history item
struct HistoryInfoView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    @Binding var isTabExpanded: Bool
    @State private var offset = 0.0
    
    @State var tabSelectedValue: String = "All"
    
    var body: some View {
        
        var uniqueDates: [String] {
            var dates = Set<String>()
            if tabSelectedValue == "All"{
                for item in viewModel.historyViewModel.allHistory{
                    let (dateComponent,_) = item.date.dateAndTimeComponents()
                    dates.insert(dateComponent)
                }
            }else{
                for item in viewModel.historyViewModel.allHistory.filter({$0.type == tabSelectedValue}){
                    let (dateComponent,_) = item.date.dateAndTimeComponents()
                    dates.insert(dateComponent)
                }
            }
            return dates.sorted(by: >)
        }
        
        GeometryReader { geometry in
                
            // Table Graphic
            VStack{
                if !isTabExpanded{
                    VStack{
                        VStack{
                            ForEach(viewModel.historyViewModel.allHistory.prefix(3),id:\.self.id){item in
                                HistoryItemDetailView(viewModel: viewModel, spotifyController: spotifyController, genreManager: genreManager, historyItem: item)
                            }
                        }.padding().background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 10.0)).padding()
                            
                        Spacer()
                    }.transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                }else{
                    VStack{
                        Picker(selection: $tabSelectedValue, label: Text("")) {
                            Text("All").tag("All")
                            Text("Listens").tag("Listen")
                            Text("Edits").tag("Edit")
                            Text("Adds").tag("Add")
                        }.pickerStyle(SegmentedPickerStyle()).padding(.horizontal,25)
                        List{
                            ForEach(uniqueDates,id:\.self){date in
                                Section(header: Text(date)){
                                    ForEach(viewModel.historyViewModel.allHistory.filter { item in
                                        let (itemDateComponent, _) = item.date.dateAndTimeComponents()
                                        return (tabSelectedValue != "All" ? (item.type == tabSelectedValue) : true) && itemDateComponent == date
                                    }, id: \.self.id){item in
                                        HistoryItemDetailView(viewModel: viewModel, spotifyController: spotifyController, genreManager: genreManager, historyItem: item)
                                            .swipeActions {
                                                Button("Delete") {
                                                    Task{
                                                        await viewModel.historyViewModel.deleteHistoryItem(id: item.id)
                                                    }
                                                }
                                                .tint(.red)
                                            }
                                    }
                                }
                            }
                        }.listStyle(.inset).cornerRadius(10).padding(5).preferredColorScheme(.light)
                            
                    }.padding(10)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
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

// History Item display view
struct HistoryItemDetailView: View{
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    @ObservedObject var genreManager: GenreManager
    
    var historyItem: HistoryItem
    
    var body: some View{
        // Set a default record until all elements are updated properly
        let record = viewModel.recordDictionaryByID[historyItem.recordID] ?? defaultRecordItems[0]
        let type = historyItem.type
        let (dateString,timeString) = historyItem.date.dateAndTimeComponents()
        
        var typeString: String {
            if type == "Edit"{
                return "Edited"
            }else if type == "Listen"{
                return "Listened to"
            }else{
                return "Added"
            }
        }
        var typeImage: String {
            if type == "Edit"{
                return "square.and.pencil"
            }else if type == "Listen"{
                return "music.quarternote.3"
            }else{
                return "plus.square.on.square"
            }
        }
        NavigationLink(destination: ShowRecordView(viewModel:viewModel,spotifyController:spotifyController, record:record, genreManager: genreManager)) {
            HStack{
                ZStack{
                    Image(uiImage:record.discPhoto)
                        .resizable()
                        .scaledToFill()
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/).frame(width:75,height: 75).clipped().offset(x:5)
                    Image(uiImage:record.coverPhoto)
                        .resizable()
                        .scaledToFill()
                        .frame(width:75,height: 75).clipped().border(decorWhite, width: 3).offset(x:-5)
                }
                HStack{
                    VStack(alignment:.leading){
                        Text(typeString).subtitleText()
                        Text(record.name).smallHeadlineText()
                        Text(record.artist).smallHeadlineText()
                    }
                    Spacer()
                    VStack(alignment:.trailing){
                        Image(systemName: typeImage).resizable().aspectRatio(contentMode: .fit)
                        Text(dateString).foregroundStyle(decorBlack.opacity(0.5)).italicSubtitleText()
                        Text(timeString).foregroundStyle(decorBlack.opacity(0.5)).italicSubtitleText()
                    }
                }.padding(.all,10.0)
                Spacer()
            }.padding(.horizontal, 10.0).frame(height:75)
        }
    }
    
    private func itemBuilder(item:HistoryItem) -> (String,RecordItem){
        let recordItem = viewModel.recordDictionaryByID[item.recordID]!
        
        let dateString = "on \(Date.dateToString(date: item.date,format: "MM-dd-yyyy HH:mm:ss"))"
        let recordString = "\(recordItem.name) by \(recordItem.artist)"
        
        var outputString = ""
        
        if item.type == "Edit"{
            outputString = "Edited "
        }else if item.type == "Listen"{
            outputString = "Listened to "
        }else{
            outputString = "Added "
        }
        outputString = outputString + recordString + dateString
        
        return (outputString,recordItem)
    }
}
