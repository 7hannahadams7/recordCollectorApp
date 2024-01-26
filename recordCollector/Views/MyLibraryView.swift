//
//  MyLibraryView.swift
//  test3
//
//  Created by Hannah Adams on 1/8/24.
//

import SwiftUI

struct MyLibraryView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @State private var sortingFactor: String = "Artist"
    @State private var sortingDirection: Bool = true
    
    var genreManager: GenreManager
    
    var body: some View {
        
        var recordLibrary: [RecordItem] {
            if sortingDirection{
                return viewModel.recordLibrary
            }else{
                return viewModel.recordLibrary.reversed()
            }
        }
        var sortingHeaders: [String]{
            var returning: [String] = []
            if sortingFactor == "Artist"{
                returning = viewModel.sortingElementHeaders.artist
            }else if sortingFactor == "Album"{
                returning = viewModel.sortingElementHeaders.album
            }else if sortingFactor == "Release Year"{
                returning = viewModel.sortingElementHeaders.releaseYear
            }
            if sortingDirection{
                return returning
            }else{
                return returning.reversed()
            }
        }
        
        NavigationView{
            ZStack{
                
                //Background Image
                ZStack{
                    Image("Page-Background").resizable().edgesIgnoringSafeArea(.all)
                }.ignoresSafeArea()
                
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
                        Button(action:{sortingDirection.toggle()}){
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
                                            NavigationLink(destination: ShowRecordView(viewModel:viewModel, record:record, genreManager: genreManager)) {
                                                PersonRowView(record:record)
                                            }
                                        }
                                    }else if sortingFactor == "Album"{
                                        ForEach(recordLibrary.filter({$0.name.first == char.first })){record in
                                            NavigationLink(destination: ShowRecordView(viewModel:viewModel, record:record, genreManager: genreManager)) {
                                                PersonRowView(record:record)
                                            }
                                        }
                                    }else if sortingFactor == "Release Year"{
                                        ForEach(recordLibrary.filter({String($0.releaseYear) == char })){record in
                                            NavigationLink(destination: ShowRecordView(viewModel:viewModel, record:record, genreManager: genreManager)) {
                                                PersonRowView(record:record)
                                            }
                                        }
                                    }
                                }
                            }
                    }.listStyle(.inset).cornerRadius(10).padding(5)
                    
                }.padding().padding(.top,35)
            }
        }
        .onAppear{
            viewModel.refreshData()
        }
    }
    
    private func sectionHeader(for record: RecordItem) -> String {
        // Provide logic to determine the section header based on the sorting factor
        switch viewModel.sortingFactor {
        case .artist:
            return String(record.artist.prefix(1)).uppercased()
        case .releaseYear:
            // Example: Group by decade
            return "\(record.releaseYear / 10)0s"
        case .album:
            // Example: Group by the first letter of the album name
            return String(record.name.prefix(1)).uppercased()
        }
    }
}

struct PersonRowView: View {
    var record: RecordItem

    var body: some View {
        HStack{
            Image(uiImage:record.photo).resizable().padding(/*@START_MENU_TOKEN@*/.all, 5.0/*@END_MENU_TOKEN@*/).frame(width:75,height:75).scaledToFill().clipped()
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
        MyLibraryView(viewModel:LibraryViewModel(), genreManager:GenreManager())
    }
}
