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
    
    var genreManager = GenreManager()
    
    @State private var filteredGenres: [String] = ["Alternative","Classic Rock"]
//    @State private var filterGenre: String = "Alternative"
    
    var body: some View {
        
        var recordLibrary: [RecordItem] {
            if sortingDirection{
                if filteredGenres != []{
                    return viewModel.recordLibrary.filter({$0.genres.contains{Set(filteredGenres).contains($0)}})
                }
                return viewModel.recordLibrary
            }else{
                if filteredGenres != []{
                    return viewModel.recordLibrary.filter({$0.genres.contains{Set(filteredGenres).contains($0)}}).reversed()
                }
                return viewModel.recordLibrary.reversed()
            }
        }
        var sortingHeaders: [String]{
            if sortingFactor == "Artist"{
                if sortingDirection{
                    return viewModel.sortingElementHeaders.artist
                }else{
                    return viewModel.sortingElementHeaders.artist.reversed()
                }
            }else if sortingFactor == "Album"{
                if sortingDirection{
                    return viewModel.sortingElementHeaders.album
                }else{
                    return viewModel.sortingElementHeaders.album.reversed()
                }
            }else if sortingFactor == "Release Year"{
                if sortingDirection{
                    return viewModel.sortingElementHeaders.releaseYear
                }else{
                    return viewModel.sortingElementHeaders.releaseYear.reversed()
                }
            }else if sortingFactor == "Date Added"{
                if sortingDirection{
                    return viewModel.sortingElementHeaders.dateAdded
                }else{
                    return viewModel.sortingElementHeaders.dateAdded.reversed()
                }
            }
            return []
        }
        
        NavigationView{
            ZStack{
                
                //Background Color
                Color(woodBrown).edgesIgnoringSafeArea(.all)
                
                // Library Layout
                VStack(spacing:5){
                    
                    //Sorting Buttons and Top Bar
                    
                    HStack{
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
                        Button{
                            sortingDirection.toggle()
                        }label: {
                            Text(sortingFactor).bold().foregroundStyle(recordBlack)
                            if sortingDirection{
                                Image(systemName:"chevron.down").foregroundStyle(recordBlack)
                            }else{
                                Image(systemName:"chevron.up").foregroundStyle(recordBlack)
                            }
                        }
                        Spacer()
                    }.frame(height:30).padding(.horizontal,10)
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 5).fill(lightWoodBrown).shadow(color:recordBlack,radius:2)
                        
                            HStack{
                                if !filteredGenres.isEmpty{
                                    Text("Filters: ")
                                    ScrollView(.horizontal){
                                        HStack{
                                            ForEach(filteredGenres, id:\.self){genre in
                                                ZStack{
                                                    HStack{
                                                        Text(genre)
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
                                    Image(systemName: "line.3.horizontal.decrease.circle").foregroundStyle(recordBlack)
                                }
                            }.padding(.horizontal)
                    }.frame(height: (!filteredGenres.isEmpty) ? 50 : 25)
                    
                    //Library Listing
                    List {
                            ForEach(sortingHeaders, id:\.self) {
                                char in
                                Section(header: Text(String(char))) {
                                    if sortingFactor == "Artist"{
                                        ForEach(recordLibrary.filter({viewModel.checkArtistHeaderMatch(record:$0, header:char)})){
                                            record in
                                            NavigationLink(destination: ShowRecordView(viewModel:viewModel,spotifyController:spotifyController, record:record, genreManager: genreManager)) {
                                                PersonRowView(record:record)
                                            }
                                        }
                                    }else if sortingFactor == "Album"{
                                        ForEach(recordLibrary.filter({$0.name.first == char.first })){record in
                                            NavigationLink(destination: ShowRecordView(viewModel:viewModel,spotifyController:spotifyController, record:record, genreManager: genreManager)) {
                                                PersonRowView(record:record)
                                            }
                                        }
                                    }else if sortingFactor == "Release Year"{
                                        ForEach(recordLibrary.filter({String($0.releaseYear) == char })){record in
                                            NavigationLink(destination: ShowRecordView(viewModel:viewModel,spotifyController:spotifyController, record:record, genreManager: genreManager)) {
                                                PersonRowView(record:record)
                                            }
                                        }
                                    }else if sortingFactor == "Date Added"{
                                        ForEach(recordLibrary.filter({$0.dateAdded == char })){record in
                                            NavigationLink(destination: ShowRecordView(viewModel:viewModel,spotifyController:spotifyController, record:record, genreManager: genreManager)) {
                                                PersonRowView(record:record)
                                            }
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
            Image(uiImage:record.coverPhoto).resizable().padding(/*@START_MENU_TOKEN@*/.all, 5.0/*@END_MENU_TOKEN@*/).frame(width:75,height:75).scaledToFill().clipped()
            VStack(alignment: .leading, spacing: 3) {
                HStack{
                    Text(record.name).bold()
                    let release = String(record.releaseYear)
                    Spacer()
                    Text(release)
                }
                Text(record.artist)
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
