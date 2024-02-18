//
//  GenericStatView.swift
//  test3
//
//  Created by Hannah Adams on 1/12/24.
//

import SwiftUI
import Charts


struct GenericStatView: View {
    @ObservedObject var viewModel: StatsViewModel
    @ObservedObject var spotifyController: SpotifyController
    var viewType: String
    
    @State private var isTabExpanded = false
    
    let typeToImages = [
        "Genres":["tabImage":"TopGenresTab","proportion":CGFloat(0.5)],
        "Artists":["tabImage":"TopArtistsTab","proportion":CGFloat(0.4)],
        "Decades":["tabImage":"TopDecadesTab","proportion":CGFloat(0.2)]
    ]
    
    var body: some View {
        // Image Selector by Name, Proportion determined above
        let tabImage = typeToImages[viewType]!["tabImage"] as! String
        let proportion: CGFloat = typeToImages[viewType]!["proportion"] as! CGFloat
        
        // Define views
        let topView = viewWindowCreator(from:viewModel,with:isTabExpanded,viewType: viewType,topFrame: true)
        let bottomView = viewWindowCreator(from:viewModel,with:isTabExpanded,viewType: viewType,topFrame: false)
        
        GeometryReader { geometry in
            
            // Adjustable widths for frame definitions based on window
            let width: CGFloat = geometry.size.width
            let graphicHeight: CGFloat = geometry.size.height*proportion
            let tabHeight: CGFloat = geometry.size.height*(1-proportion)
            let infoHeight: CGFloat = tabHeight-0.16*width
            let fullTabHeight: CGFloat = geometry.size.height
            let fullInfoHeight: CGFloat = fullTabHeight-0.16*width
            
            VStack(alignment:.center){
                
                // Top Graphic
                ZStack{
                    topView
                }.frame(width:width,height:isTabExpanded ? 0 : graphicHeight).opacity(isTabExpanded ? 0:1)

                // Bottom Info Tab
                ZStack(alignment:.bottomTrailing){
                    
                    Image(tabImage).resizable()
                        .scaledToFill()
                        .frame(width: width, height:isTabExpanded ? fullTabHeight : tabHeight, alignment: .topTrailing)
                        .clipped()
                        .shadow(color:recordBlack,radius: 5)
                    
                    ZStack(alignment:isTabExpanded ? .topTrailing: .bottomTrailing){
                        ZStack{
                            bottomView
                        }.frame(width:width,height:isTabExpanded ? fullInfoHeight: infoHeight)
                        
                        // More Info Button
                        Button(action:{isTabExpanded.toggle()}){
                            Image(systemName:isTabExpanded ? "chevron.down": "chevron.right").foregroundStyle(grayBlue)
                        }.padding()
                    }
                    
                }.frame(width:width,height:isTabExpanded ? fullTabHeight : tabHeight)
                
            }.animation(.easeInOut/*(duration:0.5)*/, value: isTabExpanded)
        }
        
        
    }
    
    // Function to create a View based on viewModel and a boolean value
    @ViewBuilder
    private func viewWindowCreator(from viewModel: StatsViewModel, with isTabExpanded: Bool,viewType: String,topFrame: Bool) -> some View {
        
        if viewType == "Genres"{
            if topFrame{
                GenrePieChart(viewModel:viewModel,isTabExpanded:isTabExpanded)
            }else{
                GenreInfoChart(viewModel:viewModel,spotifyController:spotifyController, isTabExpanded:$isTabExpanded)
            }
        }else if viewType == "Artists"{
            if topFrame{
                ArtistRecordShelf(viewModel:viewModel,isTabExpanded:isTabExpanded)
            }else{
                ArtistInfoChart(viewModel:viewModel,isTabExpanded:isTabExpanded)
            }

        }else if viewType == "Decades"{
            if topFrame{
                DecadeTopGraphic(viewModel:viewModel,isTabExpanded:isTabExpanded)
            }else{
                DecadeBottomChart(viewModel:viewModel,isTabExpanded:isTabExpanded)
            }

        }else{
            EmptyView()
        }

    }

    
    
}
