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
                            Image(systemName:sortingDirection ? "chevron.down" : "chevron.up").foregroundStyle(recordBlack)
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
                    }.frame(height: (!filteredGenres.isEmpty) ? 50 : 25).padding(5)
                    
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
            viewModel.refreshData() // COMMENT OUT FOR STAGE RUN
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
