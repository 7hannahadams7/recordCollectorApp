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
    
    let genreManager = GenreManager()
    
    var body: some View {
        
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
                    ScrollView {
                        ForEach(sortingDirection ? viewModel.recordLibrary: viewModel.recordLibrary.reversed()) {
                            record in
                            NavigationLink(destination: ShowRecordView(viewModel:viewModel, record:record, genreManager: genreManager)) {
                                PersonRowView(record:record)
                            }
                        }
                    }.padding(.top,10).cornerRadius(10).background(woodAccent)
                    
                }.padding().padding(.top,35)
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
            Image(uiImage:record.photo).resizable()
            /*.aspectRatio(contentMode:.fit)*/.padding(/*@START_MENU_TOKEN@*/.all, 5.0/*@END_MENU_TOKEN@*/).frame(width:75,height:75).scaledToFill().clipped()
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
        }.background(iconWhite).padding(.horizontal, 10.0).frame(height:75)
    }
}

struct MyLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        MyLibraryView(viewModel:LibraryViewModel())
    }
}
