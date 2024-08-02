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
            Button {
                matchManager.startMatchmaking()
            } label: {
                Text("Play")
                    .foregroundColor(Color.white)
                    .font(.largeTitle)
                    .bold()
            }
            .disabled(matchManager.authenticationState != .authenticated || matchManager.inGame)
            .padding(.vertical, 20)
            .padding(.horizontal, 100)
            .background(
                Capsule(style: .circular)
                    .fill(matchManager.authenticationState != .authenticated || matchManager.inGame ? Color.gray : Color.blue)
            )
            
            Text(matchManager.authenticationState.rawValue)
                .font(.headline.weight(.semibold))
                .foregroundColor(Color.primary)
            Spacer()
        }
    }
}

#Preview {
    MenuView(matchManager: MatchManager())
}
