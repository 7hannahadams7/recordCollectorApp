//
//  RotatingLoadingButton.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/20/24.
//

import SwiftUI

struct RotatingLoadingButton: View {
    @State private var isAnimating = false

    var body: some View {
        VStack{
            Image(systemName: "arrow.2.circlepath")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1.0)
                        .repeatForever(autoreverses: false)
                )
                .foregroundColor(decorBlack.opacity(0.5))
        }
        .onAppear() {
            isAnimating = true
        }
        .onDisappear() {
            isAnimating = false
        }
    }
}

struct RotatingLoadingButton_Previews: PreviewProvider {
    static var previews: some View {
        RotatingLoadingButton()
    }
}
