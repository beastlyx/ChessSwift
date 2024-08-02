//
//  GameOverView.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 8/1/24.
//

import SwiftUI

struct GameOverView: View {
    @ObservedObject var matchManager: MatchManager
    
    var body: some View {
        VStack {
            Spacer()
            
            //Image ??
    //        .resizable()
    //        .scaledToFill()
    //        .padding(.horizontal, 70)
    //        .padding(.vertical)
            Text("Game over by \(matchManager.message)")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color.primary)
            
            Spacer()
            
            Button {
                // TODO: Go back to menu
            } label: {
                Text("Menu")
                    .foregroundColor(Color.white)
                    .brightness(-0.8)
                    .font(.largeTitle)
                    .bold()
            }
            .padding()
            .padding(.horizontal, 50)
            .background(
                Capsule(style: .circular)
                    .fill(Color.blue)
            )
            Spacer()
        }
        .background()
        //Image ??
//        .resizable()
//        .scaledToFill()
//        .padding(.horizontal, 70)
//        .padding(.vertical)
        //.ignoresafearea()
    }
}

#Preview {
    GameOverView(matchManager: MatchManager())
}
