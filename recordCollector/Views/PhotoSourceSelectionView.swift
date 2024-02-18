//
//  PhotoSourceSelectionView.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/18/24.
//

import SwiftUI

// Presents photoLibrary and camera options for ImagePicker
struct PhotoSourceSelectionView: View {
    @Binding var isPhotoSourcePopupPresented: Bool
    @Binding var newPhoto: Bool
    var onLibrarySelected: () -> Void
    var onCameraSelected: () -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack{
                Button("Photo Library") {
                    onLibrarySelected()
                }
                .padding()
                .foregroundColor(decorBlack)
                .cornerRadius(8)
                Rectangle().frame(height:2).aspectRatio(contentMode: .fit).foregroundStyle(decorWhite)
                Button("Camera") {
                    onCameraSelected()
                }
                .padding()
                .foregroundColor(decorBlack)
                .cornerRadius(8)
                
            }.padding().frame(width:3*screenWidth/4).background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 25.0))
            VStack{
                Button("Cancel") {
                    newPhoto = false
                    isPhotoSourcePopupPresented = false
                }
                .padding()
                .foregroundColor(pinkRed)
                .cornerRadius(8)
                
            }.padding().frame(width:3*screenWidth/4).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 25.0))
            
        }
        .padding().clearModalBackground()
    }
}
