//
//  MyLibraryView.swift
//  recordCollector
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
    
    @State private var searchBarItem = ""

    @State private var filteredGenres: [String] = []
    @State private var filteredArtists: [String] = []
    @State private var usedFilters: [String] = []
    @State private var favoriteFilter: [String] = []
    
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
                                        ForEach((filteredArtists + filteredGenres + usedFilters + favoriteFilter), id:\.self){item in
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
                                                        if let index = usedFilters.firstIndex(of: item){
                                                            usedFilters.remove(at: index)
                                                        }
                                                        if let index = favoriteFilter.firstIndex(of: item){
                                                            favoriteFilter.remove(at:index)
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
                                    // Favorite Filter
                                    Button{
                                        favoriteFilter = ["Favorites"]
                                    }label:{
                                        HStack{
                                            Image(systemName: "star.fill").resizable().frame(width:20,height:20)
                                            Text("Favorites")
                                        }
                                    }
                                    
                                    // Genre Filter
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
                                    
                                    // Artist Filter
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
                                    
                                    // Condition Filter
                                    Menu{
                                        ForEach(["Used","New"], id:\.self){label in
                                            Button{
                                                if !usedFilters.contains(label){
                                                    usedFilters.append(label)
                                                }
                                            }label:{
                                                Text(label)
                                            }
                                        }
                                    }label:{
                                        Text("Condition")
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
                        HStack{
                            Image(systemName: "magnifyingglass.circle").resizable().frame(width:20,height:20).foregroundStyle(decorBlack)
                            TextField("Search Records", text: $searchBarItem)
                        }.padding(5)

                        ForEach(sortingDirection ? sortingHeaders : sortingHeaders.reversed(), id:\.self) {
                            char in
                            Section(header: Text(String(char))) {
                                ForEach(recordLibrary.filter({viewModel.headerToItemMatch(sortingFactor:sortingFactor, header:char, record: $0)})){
                                    record in
                                    NavigationLink(destination: ShowRecordView(viewModel:viewModel,spotifyController:spotifyController, record:record, genreManager: genreManager).onDisappear(){
                                        filteredGenres = []
                                    }) {
                                        PersonRowView(record:record)
                                    }.swipeActions {
                                        Button {
                                            // Call your favorite action function here
                                            Task{
                                                await viewModel.toggleFavorite(id:record.id)
                                            }// Assuming you have a function to toggle the favorite status
                                        } label: {
                                            VStack{
                                                Image(systemName: record.favorite ? "star.slash.fill" : "star.fill").resizable().frame(width:20,height:20)
                                                Text(record.favorite ? "Unfavorite" : "Favorite").subtitleText()
                                            }
                                        }
                                        .tint(yellowOrange) // Customize the color as needed
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
            filteredArtists = []
            usedFilters = []
            favoriteFilter = []
        }
    }
    
    private func filteredLibrary() -> [RecordItem] {
        var filteredRecords: [RecordItem]
        
        var usedFiltering: [Bool] {
            var output: [Bool] = []
            for filter in usedFilters{
                if filter == "Used"{
                    output.append(true)
                }else if filter == "New"{
                    output.append(false)
                }
            }
            return output
        }
        var favoriteFiltering: Bool{
            if favoriteFilter.isEmpty{
                return false
            }else{
                return true
            }
        }
        
        if filteredGenres.isEmpty && filteredArtists.isEmpty && usedFilters.isEmpty && searchBarItem.isEmpty && !favoriteFiltering{
            filteredRecords = viewModel.recordLibrary
        } else {
            filteredRecords = viewModel.recordLibrary.filter { record in
                let genresMatch = filteredGenres.isEmpty || record.genres.contains { Set(filteredGenres).contains($0) }
                let artistsMatch = filteredArtists.isEmpty || filteredArtists.contains(record.artist)
                let usedMatch = usedFiltering.isEmpty || usedFiltering.contains(record.isUsed)
                let favoriteMatch = !favoriteFiltering || record.favorite
                
                // Check if either record.artist or record.name contains the searchBarItem
                let searchMatch = searchBarItem.isEmpty ||
                                  record.artist.lowercased().contains(searchBarItem.lowercased()) ||
                                  record.name.lowercased().contains(searchBarItem.lowercased())
                
                return genresMatch && artistsMatch && usedMatch && searchMatch && favoriteMatch
            }
        }
        return sortingDirection ? filteredRecords : filteredRecords.reversed()
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
        return headers
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
            if record.favorite{
                Image(systemName: "star.fill").resizable().frame(width:20,height:20).foregroundColor(yellowOrange)
            }
        }.padding(.horizontal, 10.0).frame(height:75)
    }
}






struct MyLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        MyLibraryView(viewModel:testViewModel,spotifyController:SpotifyController(), genreManager:GenreManager()).onAppear{testViewModel.refreshData()}
    }
}
let testViewModel = LibraryViewModel()

