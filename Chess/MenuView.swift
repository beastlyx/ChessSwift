//
//  MenuView.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 8/2/24.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var matchManager: MatchManager
    var body: some View {
        VStack {
            Spacer()
            
//            Image("logo")
//                .resizable()
//                .scaledToFit()
//                .padding(30)
            
            Spacer().frame(height: 700)
            
            Button {
                matchManager.startMatchmaking()
            } label: {
                Text("Play")
                    .foregroundColor(Color.black)
                    .font(.largeTitle)
                    .bold()
            }
            
            .disabled(matchManager.authenticationState != .authenticated || matchManager.inGame)
            .padding(.vertical, 20)
            .padding(.horizontal, 100)
            .background(
                Capsule(style: .circular)
                    .fill(matchManager.authenticationState != .authenticated || matchManager.inGame ? .gray : Color("primaryYellow"))
            )
            Text(matchManager.authenticationState.rawValue)
                .font(.headline.weight(.semibold))
                .foregroundColor(Color.gray)
                .padding()
            Spacer()
        }
        .background(
        Image("chessGame")
            .resizable()
            .scaledToFill()
            .scaleEffect(1.2)
        )
        .ignoresSafeArea()
    }
}

#Preview {
    MenuView(matchManager: MatchManager())
}
