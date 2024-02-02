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
    
    var body: some View {
        
        var recordLibrary: [RecordItem] {
            if sortingDirection{
                return viewModel.recordLibrary
            }else{
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
            }
            return []
        }
        
        NavigationView{
            ZStack{
                
                //Background Image
                Color(woodBrown).edgesIgnoringSafeArea(.all)
//                ZStack{
//                    Image("Page-Background").resizable().edgesIgnoringSafeArea(.all)
//                }.ignoresSafeArea()
                
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
                        Button(action:{
                            sortingDirection.toggle()
                        }){
                            Text(sortingFactor).bold().foregroundStyle(recordBlack)
                            if sortingDirection{
                                Image(systemName:"chevron.down").foregroundStyle(recordBlack)
                            }else{
                                Image(systemName:"chevron.up").foregroundStyle(recordBlack)
                            }
                        }
                        Spacer()
                    }.frame(height:30).padding(.horizontal,10)
                    
                    Image("topShelf").resizable().frame(height:20).aspectRatio(contentMode: .fit)
                    
                    //Library Listing
                    List {
                            ForEach(sortingHeaders, id:\.self) {
                                char in
                                Section(header: Text(String(char))) {
                                    if sortingFactor == "Artist"{
                                        ForEach(recordLibrary.filter({$0.artist.first == char.first })){record in
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
//        .onAppear{
//            viewModel.refreshData()
//        }
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
