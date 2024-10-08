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

//var countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

struct GameView: View {
    @ObservedObject var matchManager: MatchManager
    @StateObject private var board = Board()
    @State private var moveMade: MoveData?
    
    func makeMove() {
        if let movedata = moveMade {
            var lastMove = self.board.moveLog.last!
            
            var move = MoveData()
            move.originalPosition = Position(x: lastMove.oldPosition.x, y: lastMove.oldPosition.y)
            move.newPosition = Position(x: lastMove.newPosition.x, y: lastMove.newPosition.y)
            move.isPromotion = lastMove.isPromotion
            move.pieceType = lastMove.piece.pieceType
            
            matchManager.sendMove(move)
            moveMade = nil
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                topBar
                
                ZStack {
                    ChessView(matchManager: matchManager, board: board, isWhite: matchManager.isWhite, currentlyMoving: matchManager.currentlyMoving, onMoveMade: { move in
                        moveMade = move
                        makeMove()
                    })

                }
                
//                promptGroup
                
            }
        }
        
    }
    
    var topBar: some View {
        ZStack {
            HStack {
                Spacer().frame(width: 20)
                Button {
                    board.reset()
                    matchManager.match?.disconnect()
                    matchManager.resetGame()
                } label: {
                    Image(systemName: "arrowshape.turn.up.left.circle.fill")
                        .font(.largeTitle)
                        .tint(Color(matchManager.currentlyMoving ? "primaryYellow" : "primaryPurple"))
                }
                Spacer()
                
                if matchManager.currentlyMoving && matchManager.isWhite || !matchManager.currentlyMoving && !matchManager.isWhite {
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
                        Text("Black to move")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.black)
                    } icon: {
                        Image("black-pawn")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34, height: 34)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 15)
    }
    
//    var promptGroup: some View {
//        VStack {
//            if matchManager.currentlyMoving {
//                Label("Your Move:", systemImage: "exclamationmark.bubble.fill")
//                    .font(.title2)
//                    .bold()
//                    .foregroundColor(.white)
//                Text(matchManager.turnPrompt.uppercased())
//                    .font(.largeTitle)
//                    .bold()
//                    .padding()
//                    .foregroundColor(Color("primaryYellow"))
//            } else {
//                HStack {
//                    Label("Opponent turn...", systemImage: "exclamationmark.bubble.fill")
//                        .font(.title2)
//                        .bold()
//                        .foregroundColor(Color("primaryPurple"))
//                    
//                    Spacer()
//                }
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .padding([.horizontal, .bottom], 30)
//        .padding(.vertical)
//    }
}

#Preview {
    GameView(matchManager: MatchManager())
}
