//
//  MyLibraryView.swift
//  test3
//
//  Created by Hannah Adams on 1/8/24.
//

import SwiftUI



struct MyLibraryView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var spotifyController: SpotifyController
    
    @State private var sortingFactor: String = "Artist"
    @State private var sortingDirection: Bool = true
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var genreManager: GenreManager
    
    @State private var filteredGenres: [String] = []
    @State private var filteredArtists: [String] = []
    
    var body: some View {
        
        // Pull sorted and filtered library and headers for sections
        let recordLibrary = filteredLibrary()
        let sortingHeaders = filteredHeaders(filteredLibrary: recordLibrary)
        
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
                            Text(sortingFactor).smallHeadlineText().foregroundStyle(recordBlack)
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
                                        ForEach((filteredArtists + filteredGenres), id:\.self){item in
                                            ZStack{
                                                HStack{
                                                    Text(item).subtitleText()
                                                    Button{
                                                        if let index = filteredGenres.firstIndex(of: item) {
                                                            filteredGenres.remove(at: index)
                                                        }
                                                        if let index = filteredArtists.firstIndex(of: item) {
                                                            filteredArtists.remove(at: index)
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
                                    
                                    Menu {
                                        ForEach(viewModel.fullArtists.sorted(), id:\.self){artist in
                                            Button{
                                                if !filteredArtists.contains(artist){
                                                    filteredArtists.append(artist)
                                                }
                                            }label:{
                                                Text(artist)
                                            }
                                        }
                                    }label:{
                                        Text("Artists")
                                    }
                                } label: {
                                    Image(systemName: "line.3.horizontal.decrease.circle").resizable().padding(3).frame(width:30,height:30).foregroundStyle(recordBlack)
                                        .aspectRatio(contentMode: .fit)
                                }
                            }.padding(.horizontal)
                    }.frame(height: 50).padding(5)
                    
                    //Library Listing
                    List {
                        // Apply direction change here, library instances are called according to headers anyway
                        ForEach(sortingDirection ? sortingHeaders : sortingHeaders.reversed(), id:\.self) {
                            char in
                            Section(header: Text(String(char))) {
                                ForEach(recordLibrary.filter({viewModel.headerToItemMatch(sortingFactor:sortingFactor, header:char, record: $0)})){
                                        record in
                                    NavigationLink(destination: ShowRecordView(viewModel:viewModel,spotifyController:spotifyController, record:record, genreManager: genreManager).onDisappear(){
                                        filteredGenres = []
                                    }) {
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
            
        }.onAppear{
            // Reset and redefine library view when navigated to
            filteredGenres = []
//            viewModel.refreshData()
        }
    }
    
    private func filteredLibrary() -> [RecordItem] {
        var filteredRecords: [RecordItem]
        
        if filteredGenres.isEmpty && filteredArtists.isEmpty {
            filteredRecords = viewModel.recordLibrary
        } else {
            filteredRecords = viewModel.recordLibrary.filter { record in
                let genresMatch = filteredGenres.isEmpty || record.genres.contains { Set(filteredGenres).contains($0) }
                let artistsMatch = filteredArtists.isEmpty || filteredArtists.contains(record.artist)
                
                return genresMatch && artistsMatch
            }
        }
        return filteredRecords
    }

    
    private func filteredHeaders(filteredLibrary: [RecordItem]) -> [String]{
        var headers: [String] = []
        for record in filteredLibrary{
            if sortingFactor == "Artist"{
                var char = ""
                if record.isBand {
                    let components = record.artist.components(separatedBy: " ")
                    char = String((components.first == "The" ? components.dropFirst().joined(separator: " ") : components.first ?? "z").first!)
                } else {
                    char = String((record.artist.components(separatedBy: " ").last ?? "z").first!)
                }
                if !headers.contains(char){
                    headers.append(char)
                }
            }else if sortingFactor == "Album"{
                if let character = record.name.first, !headers.contains(String(character)) {
                    headers.append(String(character))
                }
            }else if sortingFactor == "Release Year"{
                if !headers.contains(String(record.releaseYear)){
                    headers.append(String(record.releaseYear))
                }
            }else{
                if !headers.contains(record.dateAdded){
                    headers.append(record.dateAdded)
                }
            }
        }
        
        if sortingFactor == "Date Added"{
            let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy"
            headers.sort {
                // Sort chronologically by actual date
                guard let date1 = String.stringToDate(from: $0),
                      let date2 = String.stringToDate(from: $1) else {
                    return false // Handle invalid date strings as needed
                }
                return date1 > date2
            }
            return headers
        }else{
            return headers.sorted(by: {$0 < $1})
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
                Text(record.name).smallHeadlineText().minimumScaleFactor(0.9)
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
        MyLibraryView(viewModel:testViewModel,spotifyController:SpotifyController(), genreManager:GenreManager()).onAppear{testViewModel.refreshData()}
    }
}
let testViewModel = LibraryViewModel()

