//
//  Settings.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/10/24.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @ObservedObject var authManager: AuthenticationManager
    @ObservedObject var spotifyController: SpotifyController

    var body: some View {
            
            //Background Decor
            ZStack{
                
                //Background Image
                Color(woodBrown).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                
                VStack{
//                    ZStack{
//                        Circle().fill(iconWhite).aspectRatio(contentMode:.fill)
//                        Image("TakePhoto")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .clipShape(Circle())
//                            .padding(8)
//                    }.frame(width:150,height:150).padding()
                    
                    List{
                        Section(header: Text("Account")) {
                            HStack{
                                Text("Username:")
                                Spacer()
                                Text(String(Auth.auth().currentUser?.email ?? "")).subtitleText()
                            }
                            Button{
                                signOut()
                            }label:{
                                HStack{
                                    Spacer()
                                    Text("Sign Out")
                                        .foregroundStyle(pinkRed)
                                        .bold()
                                    Spacer()
                                }
                            }
                        }
                        Section(header: Text("Spotify")) {
                            HStack{
                                Text("Connected:")
                                Spacer()
                                if spotifyController.connectionFailure{
                                    Image(systemName:"xmark.circle.fill").resizable().frame(width:20,height:20).foregroundStyle(pinkRed)
                                }else{
                                    Image(systemName:"checkmark.circle.fill").resizable().frame(width:20,height:20).foregroundStyle(seaweedGreen)
                                }
                            }
                            if spotifyController.connectionFailure{
                                Button{
                                    spotifyController.connect()
                                }label:{
                                    HStack{
                                        Spacer()
                                        Text("Connect Spotify").bold()
                                        Spacer()
                                    }
                                }
                            }else{
                                Button{
                                    spotifyController.disconnect()
                                }label:{
                                    HStack{
                                        Spacer()
                                        Text("Disconnect Spotify").foregroundStyle(pinkRed).bold()
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }.listStyle(.inset).cornerRadius(10).padding(25).preferredColorScheme(.light).frame(height:350)

                    Spacer()
                    
                }.padding(.top,75)

            }.ignoresSafeArea()

    }
    
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            authManager.isUserSignedIn = false
            print("User signed out successfully")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
            
}

#Preview {
    SettingsView(authManager:AuthenticationManager(),spotifyController:SpotifyController())
}
