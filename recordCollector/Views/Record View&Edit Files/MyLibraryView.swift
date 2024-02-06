//
//  MyLibraryView.swift
//  test3
//
//  Created by Hannah Adams on 1/8/24.
//

import SwiftUI

extension Text {
    func headlineText() -> some View{
        self.font(.system(size: 16)).bold()
    }
    
    func mainText() -> some View{
        self.font(.system(size: 16))
    }
    
    func subtitleText() -> some View {
        self.font(.system(size: 12))
    }
    
    func italicSubtitleText() -> some View{
        self.font(.system(size: 12)).italic()
    }
}

struct MyLibraryView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    
    @State private var sortingFactor: String = "Artist"
    @State private var sortingDirection: Bool = true
    
    @Environment(\.presentationMode) var presentationMode
    
    var genreManager = GenreManager()
    
    @State private var filteredGenres: [String] = []
    
    var body: some View {
        
        // Pull sorted and filtered library and headers for sections
        let (recordLibrary, sortingHeaders) = viewModel.filteredLibrary(sortingFactor:sortingFactor, sortingDirection:sortingDirection,filteredGenres:!filteredGenres.isEmpty ? filteredGenres : viewModel.fullGenres.sorted())
        
        NavigationView{
            ZStack{
                
                //Background Color
                Color(woodBrown).edgesIgnoringSafeArea(.all)
                
                // Library Layout
                VStack(spacing:5){
                    
                    //Sorting Buttons and Top Bar
                    
                    HStack{
                        // Sorting Factor Selection
                        Menu {
                            ForEach(LibraryViewModel.SortingFactor.allCases, id: \.self) { factor in
                                Button(action: {
                                    viewModel.sortingFactor = factor
                                    sortingFactor = factor.rawValue
                                }) {
                                    Text(factor.rawValue)
                                }
                            }
                        } label: {
                            Image("SortBy").resizable().aspectRatio(contentMode: .fit)
                        }.frame(height:30)
                        
                        // Sorting Direction Toggle
                        Button{
                            sortingDirection.toggle()
                        }label: {
                            Text(sortingFactor).headlineText().foregroundStyle(recordBlack)
                            Image(systemName:sortingDirection ? "chevron.down" : "chevron.up").foregroundStyle(recordBlack)
                        }
                        Spacer()
                    }.frame(height:30).padding(.horizontal,10)
                    
                    // Filter Bar
                    ZStack{
                        RoundedRectangle(cornerRadius: 5).fill(lightWoodBrown).shadow(color:recordBlack,radius:2)
                        
                            HStack{
                                Text("Filters: ").mainText()
                                // Display Current Filters
                                ScrollView(.horizontal){
                                    HStack{
                                        ForEach(filteredGenres, id:\.self){genre in
                                            ZStack{
                                                HStack{
                                                    Text(genre).subtitleText()
                                                    Button{
                                                        if let index = filteredGenres.firstIndex(of: genre) {
                                                            filteredGenres.remove(at: index)
                                                        }
                                                    }label:{
                                                        Image(systemName: "xmark").foregroundColor(recordBlack)
                                                    }
                                                }.padding(8).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 5))
                                            }
                                        }
                                    }
                                }
                                Spacer()
                                Menu {
                                    Menu {
                                        ForEach(viewModel.fullGenres.sorted(), id:\.self){genre in
                                            Button{
                                                if !filteredGenres.contains(genre){
                                                    filteredGenres.append(genre)
                                                }
                                            }label:{
                                                Text(genre)
                                            }
                                        }
                                    }label:{
                                        Text("Genres")
                                    }
                                } label: {
                                    Image(systemName: "line.3.horizontal.decrease.circle").resizable().padding(3).frame(width:30,height:30).foregroundStyle(recordBlack)
                                        .aspectRatio(contentMode: .fit)
                                }
                            }.padding(.horizontal)
                    }.frame(height: 50).padding(5)
                    
                    //Library Listing
                    List {
                        ForEach(sortingHeaders, id:\.self) {
                            char in
                            Section(header: Text(String(char))) {
                                ForEach(recordLibrary.filter({viewModel.headerToItemMatch(sortingFactor:sortingFactor, header:char, record: $0)})){
                                        record in
                                    NavigationLink(destination: ShowRecordView(viewModel:viewModel,spotifyController:spotifyController, record:record, genreManager: genreManager)) {
                                        PersonRowView(record:record)
                                    }
                                }
                            }
                        }
                    }.listStyle(.inset).cornerRadius(10).padding(5).preferredColorScheme(.light)
                    
                }.padding().padding(.top,35)
                
                //Add New Button
                VStack{
                    HStack{
                        Spacer()
                        NavigationLink(destination: AddRecordView(viewModel:viewModel,genreManager:genreManager)) {
                            Image("AddButton").resizable().frame(width:80,height:80).shadow(color:Color.black,radius:2)
                        }
                    }.padding(.trailing,15)
                    Spacer()
                }
            }
            
        }
        .onAppear{
            viewModel.refreshData()
        }
    }
    
}

struct PersonRowView: View {
    var record: RecordItem

    var body: some View {
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
            VStack(alignment: .leading, spacing: 3) {
                Text(record.name).headlineText().minimumScaleFactor(0.9)
                Text(record.artist).mainText()
                Text(String(record.releaseYear)).subtitleText()
                Text(record.dateAdded).subtitleText()
            }.padding(.all,10.0)
            Spacer()
        }.padding(.horizontal, 10.0).frame(height:75)
    }
}

struct MyLibraryView_Previews: PreviewProvider {

    static var previews: some View {
        MyLibraryView(viewModel:LibraryViewModel(),spotifyController:SpotifyController(), genreManager:GenreManager())
    }
}
