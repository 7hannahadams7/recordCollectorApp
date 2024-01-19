//
//  ContentView.swift
//  test3
//
//  Created by Hannah Adams on 1/8/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @State var selectedTab = 0
//    @ObservedObject var statsViewModel: StatsViewModel
//    @State private var s  let snapshot = try await ref.child("users/\(uid)/username").getData()
//    let userName = snapshot.value as? String ?? "Unknown"electedTab = 0
    
    var body: some View {
        NavigationView{
            ZStack{
                TabView(selection: $selectedTab){
                    HomePageView().tabItem{
                        Image(systemName:"house.fill")
                        Text("Home").bold()
                    }.tag(0)
                    MyLibraryView(viewModel:viewModel).tabItem{
                        Image(systemName:"filemenu.and.selection")
                        Text("My Library").bold()
                    }.tag(1)
                    MyStatsView(viewModel:viewModel).tabItem{
                        Image(systemName:"chart.pie.fill").foregroundColor(.blue)
                        Text("My Stats").bold()
                    }.tag(2)
                    SettingsView().tabItem{
                        Image(systemName:"gearshape")
                        Text("Settings").bold()
                    }.tag(3)
                    
                }.accentColor(redBrown)
                VStack{
                    HStack{
                        Spacer()
                        if selectedTab == 0 || selectedTab == 1{
                            NavigationLink(destination: AddRecordView(viewModel:viewModel)) {
                                Image("AddButton").resizable().frame(width:80,height:80).shadow(color:Color.black,radius:2)
                            }
                        }
                    }.padding(.trailing,15)
                    Spacer()
                }
            }
            
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel:LibraryViewModel())
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

//Custom Color Definitions

let woodBrown = Color(hex:"BC8F5E")
let lightWoodBrown = Color(hex:"E2AB74")
let woodAccent = Color(hex:"9E7852")

let recordBlack = Color(hex:"0C0C0C")
let decorBlack = Color(hex:"1A1A1A")
let iconWhite = Color(hex:"FBFFFE")
let decorWhite = Color(hex:"EAE7E4")

let mintGreen = Color(hex: "BFC8AD")
let seaweedGreen = Color(hex: "475841")
let blueGreen = Color(hex: "2B4141")
let grayBlue = Color(hex: "7D869C")
let deepBlue = Color(hex: "2E294E")

let yellowOrange = Color(hex: "CC8229")
let paleRed = Color(hex: "A97C73")
let pinkRed = Color(hex:"A63A50")
let redBrown = Color(hex:"3F0D12")
let darkRedBrown = Color(hex:"1E000E")

let smallDisplayColors: [Color] = [seaweedGreen,blueGreen,deepBlue,redBrown,pinkRed,yellowOrange]

let fullDisplayColors: [Color] = [seaweedGreen, blueGreen,deepBlue,darkRedBrown,redBrown,pinkRed,yellowOrange,lightWoodBrown,paleRed,grayBlue,mintGreen]
let totalDisplayColors = fullDisplayColors.count
