//
//  Settings.swift
//  test3
//
//  Created by Hannah Adams on 1/10/24.
//

import SwiftUI

struct SettingsView: View {

    var body: some View {
            
            //Background Decor
            ZStack{
                
                //Background Image
                Image("Page-Background").resizable().edgesIgnoringSafeArea(.all)
                Text("Settings Page")

            }.ignoresSafeArea()

    }
            
    }

#Preview {
    SettingsView()
}
