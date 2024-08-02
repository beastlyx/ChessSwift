//
//  ContentView.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 8/2/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var matchManager = MatchManager()
    
    var body: some View {
        ZStack {
            if matchManager.isGameOver {
                GameOverView(matchManager: matchManager)
            } else if matchManager.inGame {
                PlayerVersusPlayerView(matchManager: matchManager)
            } else {
                MainMenuView(matchManager: matchManager)
            }
        }
        .onAppear {
            matchManager.authentizateUser()
        }
    }
}

#Preview {
    ContentView()
}
