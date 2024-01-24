//
//  MyStats.swift
//  test3
//
//  Created by Hannah Adams on 1/10/24.
//

import SwiftUI

struct MyStatsView: View {
    @State private var displayTag = 0
    @ObservedObject var viewModel: LibraryViewModel
    
    var body: some View {
        let genresView = GenericStatView(viewModel:StatsViewModel(viewModel:viewModel),viewType:"Genres")
        let artistsView = GenericStatView(viewModel:StatsViewModel(viewModel:viewModel),viewType:"Artists")
        let decadesView = GenericStatView(viewModel:StatsViewModel(viewModel:viewModel),viewType:"Decades")
        let storesView = GenericStatView(viewModel:StatsViewModel(viewModel:viewModel),viewType:"Artists")
        let historyView = GenericStatView(viewModel:StatsViewModel(viewModel:viewModel),viewType:"Artists")
        
            //Background Decor
            ZStack{
                
                //Background Image
                Image("Page-Background").resizable().edgesIgnoringSafeArea(.all)
                
                VStack{
                    HStack{
                        Button(action:{displayTag = 0}){
                            Image("GenresTab").resizable().aspectRatio(contentMode: .fit)
                                .shadow(color: displayTag==0 ? recordBlack.opacity(1.0) : .clear, radius: 5)
                        }
                        Button(action:{displayTag = 1}){
                            Image("ArtistsTab").resizable().aspectRatio(contentMode: .fit).shadow(color: displayTag==1 ? recordBlack.opacity(1.0) : .clear, radius: 5)
                        }
                        Button(action:{displayTag = 2}){
                            Image("DecadesTab").resizable().aspectRatio(contentMode: .fit).shadow(color: displayTag==2 ? recordBlack.opacity(1.0) : .clear, radius: 5)
                        }

                    }.frame(height:40).padding(.horizontal,10).padding(.top,30)
                    HStack{
                        Button(action:{displayTag = 3}){
                            Image("StoresTab").resizable().aspectRatio(contentMode: .fit).shadow(color: displayTag==3 ? recordBlack.opacity(1.0) : .clear, radius: 5)
                        }
                        Button(action:{displayTag = 4}){
                            Image("HistoryTab").resizable().aspectRatio(contentMode: .fit).shadow(color: displayTag==4 ? recordBlack.opacity(1.0) : .clear, radius: 5)
                        }

                    }.frame(height:40).padding()
                    
                    ZStack(alignment:.topLeading){
                        if displayTag == 0{
                            genresView
                        }else if displayTag == 1{
                            artistsView
                        }else if displayTag == 2{
                            decadesView
                        }else if displayTag == 3{
                            storesView
                        }else{
                            historyView
                        }
                    }.frame(width:screenWidth,height:7*screenHeight/12)
                    
                    Spacer()
                    
                }.padding()
            

            }

    }
            
    }

struct ArtistsView: View {
    var body: some View {
        ZStack{
            Rectangle().fill(blueGreen)
            Text("Artists Page")
        }
    }
}

struct DecadesView: View {
    var body: some View {
        ZStack{
            Rectangle().fill(deepBlue)
            Text("Decades Page")
        }
    }
}

struct StoresView: View {
    var body: some View {
        ZStack{
            Rectangle().fill(pinkRed)
            Text("Stores Page")
        }
    }
}

struct HistoryView: View {
    var body: some View {
        ZStack{
            Rectangle().fill(yellowOrange)
            Text("History Page")
        }
    }
}

#Preview {
    MyStatsView(viewModel:LibraryViewModel())
}
