//
//  HomePageView.swift
//  test3
//
//  Created by Hannah Adams on 1/8/24.
//

import SwiftUI


let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height


struct HomePageView: View {
    
    private var topStack: CGFloat = 100
    private var bottomStack: CGFloat = 125
    
    @State private var isAddItemSheetPresented = false

    var body: some View {
        
            //Background Decor
            ZStack{
                
                
                //Background Image
                Image("Main-Page-Background-1").resizable().edgesIgnoringSafeArea(.all)
                
                //Foreground Decor (with shelves and records)
                VStack{
                    
                    Spacer()
                    
                    //Top Record Shelf
                    ZStack{
                        HStack{
                            Image("TalkingHeads").resizable().frame(width: topStack, height: topStack, alignment: .center)
                            Image("DavidBowie").resizable().frame(width: topStack, height: topStack, alignment: .center)
                            Image("PinkFloyd").resizable().frame(width: topStack, height: topStack, alignment: .center)
                            
                        }.shadow(color:Color.black,radius:2)
                        Image("topShelf").resizable().frame( alignment: .bottom).aspectRatio(contentMode: .fit).offset(y:topStack/2)
                    }.frame(height: topStack+25, alignment: .center)
                    
                    //Bottom Shelves
                    ZStack(alignment:.top){
                        HStack{
                            Image("Radiohead").resizable().frame(width: bottomStack, height: bottomStack, alignment: .center)
                            Image("S&G").resizable().frame(width: bottomStack, height: bottomStack, alignment: .center)
                            Image("LedZeppelin").resizable().frame(width: bottomStack, height: bottomStack, alignment: .center)
                            Image("TheSmiths").resizable().frame(width: bottomStack, height: bottomStack, alignment: .center)
                            
                        }.shadow(color:Color.black,radius:3).offset(y:-bottomStack+20)
                        
                        Image("frontShelves-1").resizable().aspectRatio(contentMode: .fit)
                        
                    }.frame(width: screenWidth, height:screenWidth+bottomStack+50,alignment:.bottom)
                    
                }.ignoresSafeArea()

                
            }
        
        }
    }
            




struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
