////
////  GameView.swift
////  Chess
////
////  Created by Borys Banaszkiewicz on 8/2/24.
////
//
//import SwiftUI
//
//var countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//

import SwiftUI

var countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

struct GameView: View {
    @ObservedObject var matchManager: MatchManager
    @State var moveMade = ""
    
    func makeMove() {
        guard !moveMade.isEmpty else { return }
        matchManager.sendMove("move:\(moveMade)")
        moveMade = ""
    }
    
    var body: some View {
        ZStack {
            VStack {
                topBar
                
                ZStack {
                    ChessGameView(matchManager: matchManager, moveMade: $moveMade)
                }
                
                promptGroup
                
            }
            .onReceive(countdownTimer) { _ in
                guard matchManager.isTimeKeeper else { return }
                matchManager.remainingTime -= 1
            }
        }
        
    }
    
    var topBar: some View {
        ZStack {
            HStack {
                Spacer().frame(width: 20)
                Button {
                    matchManager.match?.disconnect()
                    matchManager.resetGame()
                } label: {
                    Image(systemName: "arrowshape.turn.up.left.circle.fill")
                        .font(.largeTitle)
                        .tint(Color(matchManager.currentlyMoving ? "primaryYellow" : "primaryPurple"))
                }
                Spacer()
                
                if matchManager.currentlyMoving {
                    Label {
                        Text("White to move")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.black)
                    } icon: {
                        Image("white-pawn")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34, height: 34)
                    }
                } else {
                    Label {
                        Text("...")
                    } icon: {
                        Image("black-pawn")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34, height: 34)
                    }
                }
                
                Spacer()
                Label("\(matchManager.remainingTime)",
                      systemImage: "clock.fill")
                .bold()
                .font(.title2)
                .foregroundColor(Color(matchManager.currentlyMoving ? "primaryYellow" : "primaryPurple"))
                Spacer().frame(width: 20)
            }
        }
        .padding(.vertical, 15)
    }
    
    var promptGroup: some View {
        VStack {
            if matchManager.currentlyMoving {
                Label("Your Move:", systemImage: "exclamationmark.bubble.fill")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                Text(matchManager.turnPrompt.uppercased())
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .foregroundColor(Color("primaryYellow"))
            } else {
                HStack {
                    Label("Opponent turn...", systemImage: "exclamationmark.bubble.fill")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color("primaryPurple"))
                    
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    Button {
                        makeMove()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .renderingMode(.original)
                            .foregroundColor(.green)
                            .font(.system(size: 50))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding([.horizontal, .bottom], 30)
        .padding(.vertical)
    }
}

#Preview {
    GameView(matchManager: MatchManager())
}
