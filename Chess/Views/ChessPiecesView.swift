//
//  ChessPiecesView.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 7/31/24.
//

import SwiftUI

struct ChessPiecesView: View {
    @ObservedObject var board: Board
    var squareSize: CGFloat
    @Binding var selectedPiece: GamePiece?
    @Binding var legalMoves: [(Int, Int)]
    @Binding var legalCaptures: [(Int, Int)]
    @Binding var selectedPosition: (Int, Int)?
    @Binding var whiteMove: Bool
    @Binding var isMate: Bool
    @Binding var selectedMoveIndex: Int?
    @State private var isPieceSelected = false
    @State private var dragOffset = CGSize.zero
    @State private var draggedPiece: GamePiece?
    @State private var initialPosition: (Int, Int)?
    @State private var enPassantPosition: (Int, Int)?
    @State private var glowOpacity = 0.3
//    var flipped: Bool
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    let checkFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        if let lastMove = board.getMoveLog().last {
            if lastMove.isCheck == true {
                ZStack {
                    let (kingRow, kingCol) = self.board.getKingPosition(color: whiteMove ? "white" : "black")
//                    let (displayRow, displayCol) = flipped ? (7 - kingRow, 7 - kingCol) : (kingRow, kingCol)
                    RadialGradient(colors: [.red, .clear], center: .center, startRadius: 10, endRadius: 30)
                        .frame(width: squareSize, height: squareSize)
                        .position(x: CGFloat(kingCol) * (squareSize) + (squareSize / 2) * 1.43, y: CGFloat(kingRow) * (squareSize) + (squareSize / 2) * 1.44)
                        .opacity(glowOpacity)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                glowOpacity = 1.0
                            }
                        }
                        .onDisappear {
                            glowOpacity = 0.2
                        }
                }
            }
        }
        VStack(spacing: 0) {
            
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { col in
//                        let displayRow = flipped ? 7 - row : row
//                        let displayCol = flipped ? 7 - col : col
                        ZStack {
                            if let ep = enPassantPosition, ep == (row, col) {
                                RadialGradient(colors: [.red, .red], center: .center, startRadius: 15, endRadius: 30)
                                    .position(x: CGFloat(squareSize * 0.5), y: CGFloat(squareSize * 0.5))
//                                    .opacity(0.8)
                                
                            }
                            if legalMoves.contains(where: { $0 == (row, col)}) {
                                if legalCaptures.contains(where: { $0 == (row, col) }) {
                                    RadialGradient(colors: [.red, .red], center: .center, startRadius: 15, endRadius: 30)
                                        .position(x: CGFloat(squareSize * 0.5), y: CGFloat(squareSize * 0.5))
//                                        .opacity(0.8)
                                        .onTapGesture {
                                            feedbackGenerator.impactOccurred()
                                            movePiece(to: (row, col))
                                        }
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.9))
                                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 2, y: 2)
                                        .frame(width: squareSize * 0.4, height: squareSize * 0.4)
                                        .onTapGesture {
                                            feedbackGenerator.impactOccurred()
                                            movePiece(to: (row, col))
                                        }
                                }
                            }
                            if let piece = board.getPiece(row: row, col: col) {
                                Image(uiImage: piece.img!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: squareSize, height: squareSize)
                                    .scaledToFit()
                                    .scaleEffect(isSelectedPosition(row: row, col: col) ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: isPieceSelected)
                                    .shadow(color: Color.black.opacity(0.4), radius: 2, x: 1, y: 1)
                                    .rotationEffect(isMate && piece.pieceType == "king" && (piece.color == "white" && whiteMove || piece.color == "black" && !whiteMove) ? .degrees(-90) : .degrees(0))
                                    .onTapGesture {
                                        feedbackGenerator.impactOccurred()
                                        if legalCaptures.contains(where: { $0 == (row, col) }) {
                                            movePiece(to: (row, col))
                                        } else {
                                            selectPiece(piece: piece, at: (row, col))
                                        }
                                    }
                            }
                        }
                        .frame(width: squareSize, height: squareSize)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPiece = nil
                            legalMoves = []
                            legalCaptures = []
                            selectedPosition = nil
                            enPassantPosition = nil
                        }
                    }
                }
            }
        }
    }
    
    private func getEnPassantPosition() {
        if let selectedPiece = selectedPiece as? Pawn, selectedPiece.isEnPassant {
            enPassantPosition = (selectedPiece.enPassantPosition.0, selectedPiece.enPassantPosition.1)
        }
        else {
            enPassantPosition = nil
        }
    }
    
    private func isSelectedPosition(row: Int, col: Int) -> Bool {
        if let selectedPosition = selectedPosition {
            return selectedPosition == (row, col)
        }
        return false
    }
    
    private func selectPiece(piece: GamePiece, at position: (Int, Int)) {
        if whiteMove && piece.color == "white" || !whiteMove && piece.color == "black" {
            selectedPiece = piece
            selectedPosition = position
            piece.setLegalMoves(board: self.board)
            legalMoves = piece.validateLegalMoves(board: self.board)
            legalCaptures = piece.getLegalCaptures(board: self.board)
            isPieceSelected = true
            getEnPassantPosition()
        }
        else {
            selectedPiece = nil
            legalMoves = []
            legalCaptures = []
            selectedPosition = nil
            enPassantPosition = nil
        }
    }

    private func movePiece(to newPos: (Int, Int)) {
        guard let piece = selectedPiece, let _ = selectedPosition else { return }
        board.movePiece(piece: piece, newPosition: newPos)
        board.undoneMoves.reset()

        selectedMoveIndex = board.getMoveLog().count - 1

        isMate = board.getMoveLog().last?.isCheckmate == true ? true : false
        
        whiteMove.toggle()
        selectedPiece = nil
        selectedPosition = nil
        legalMoves = []
        legalCaptures = []
        isPieceSelected = false
        dragOffset = .zero
        draggedPiece = nil
        enPassantPosition = nil
    }
}
