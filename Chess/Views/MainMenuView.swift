//
//  MainMenuView.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 7/29/24.
//

import SwiftUI

struct MainMenuView: View {
    @ObservedObject var matchManager: MatchManager
    var body: some View {
        NavigationView {
            VStack {
                Text("Chess")
                    .font(.largeTitle)
                    .padding()

//                NavigationLink(destination: PlayAgainstBotView()) {
//                    Text("Play Against Bot (comming soon)")
//                }
//                .padding()
//
                NavigationLink(destination: PlayerVersusPlayerView(matchManager: MatchManager())) {
                    Text("Play Against Player (comming soon)")
                }
                .padding()

                NavigationLink(destination: ExplorerView()) {
                    Text("Explorer")
                }
                .padding()

                NavigationLink(destination: AnalyzeGamesView()) {
                    Text("Analyze Previous Games")
                }
                .padding()
                
                NavigationLink(destination: AboutView()) {
                    Text("About")
                }
                .padding()
            }
        }
    }
}

#Preview {
    MainMenuView(matchManager: MatchManager())
}
