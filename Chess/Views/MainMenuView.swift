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

                .background()
                Spacer()
                NavigationLink(destination: MenuView(matchManager: matchManager)) {
                    Text("Play Against Player")
                    .padding(.vertical, 20)
                    .padding(.horizontal, 50)
                    .background(
                        Capsule(style: .circular)
                            .fill(Color.blue)
                            .frame(width: 250)
                    )
                    .foregroundColor(.white)
                    .bold()
                }

                .padding()

                NavigationLink(destination: ExplorerView()) {
                    Text("Explorer")
                    .padding(.vertical, 20)
                    .padding(.horizontal, 50)
                    .background(
                        Capsule(style: .circular)
                            .fill(Color.blue)
                            .frame(width: 250)
                    )
                    .foregroundColor(.white)
                    .bold()
                }
                .padding()

                NavigationLink(destination: AnalyzeGamesView()) {
                    Text("Analyze Previous Games")
                    .padding(.vertical, 20)
                    .padding(.horizontal, 50)
                    .background(
                        Capsule(style: .circular)
                            .fill(Color.blue)
                            .frame(width: 250)
                    )
                    .foregroundColor(.white)
                    .bold()
                }
                .padding()
                
                NavigationLink(destination: AboutView()) {
                    Text("About")
                        .padding(.vertical, 20)
                        .padding(.horizontal, 50)
                        .frame(width: 250)
                        .background(
                            Capsule(style: .circular)
                                .fill(Color.blue)
                        )
                        .foregroundColor(.white)
                        .bold()
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

#Preview {
    MainMenuView(matchManager: MatchManager())
}
//                .background(
//                    Capsule(style: .circular)
//                        .fill(Color("primaryYellow"))
//                )
//                .scaledToFit()
