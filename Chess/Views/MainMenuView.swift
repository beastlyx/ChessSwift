//
//  MainMenuView.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 7/29/24.
//

import SwiftUI

struct MainMenuView: View {
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
                NavigationLink(destination: PlayerVersusPlayerView()) {
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
    MainMenuView()
}
