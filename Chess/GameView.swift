//
//  GameView.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 8/2/24.
//

import SwiftUI

var countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

struct GameView: View {
    @ObservedObject var matchManager: MatchManager
    @ObservedObject private var board = Board()
    @State private var selectedPiece: GamePiece?
    @State private var legalMoves: [(Int, Int)] = []
    @State private var legalCaptures: [(Int, Int)] = []
    @State private var selectedPosition: (Int, Int)?
    @State private var whiteMove = true
    @State private var isMate: Bool = false
    @State private var selectedMoveIndex: Int? = nil
    @State private var showingPromotionDialog = false
    @State private var promotionDetails: (Int, Int, String, (GamePiece) -> Void)?
    @State private var lightSquareColor: Color = UserDefaults.standard.color(forKey: "lightSquareColor") ?? .white
    @State private var darkSquareColor: Color = UserDefaults.standard.color(forKey: "darkSquareColor") ?? Color(red: 218/255, green: 140/255, blue: 44/255)
    @State private var showingEditBoardView = false
    @State private var flipped = false
    
    func makeMove(from: (Int, Int), to: (Int, Int), isPromotion: Bool, pieceType: String) {
        let moveData = MoveData(oldRow: from.0, oldCol: from.1, newRow: to.0, newCol: to.1, isPromotion: isPromotion, pieceType: pieceType)
        matchManager.sendMove(moveData)
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height * 0.7)
                VStack {
                    topBar
                    HStack(spacing: 0) {
                        CapturedPiecesView(capturedPieces: board.capturedPieces.getWhiteCapturedPieces())
                        Spacer()
                        if let pointDifference = pointDifference(), pointDifference > 0 {
                            Text("+\(pointDifference)")
                                .foregroundColor(Color.black.opacity(0.5))
                                .padding(.leading, 5)
                        }
                    }
                    .frame(height: 20)
                    .padding(.horizontal, 10)
                    
                    ZStack {
                        let squareSize = size / 8
                        ChessBorderView(squareSize: squareSize, color1: lightSquareColor, color2: darkSquareColor, flipped: flipped)
                            .frame(width: size, height: size)
                        
                        PiecesView(board: board, matchManager: matchManager, squareSize: squareSize * 0.95, selectedPiece: $selectedPiece, legalMoves: $legalMoves, legalCaptures: $legalCaptures, selectedPosition: $selectedPosition, whiteMove: $whiteMove, isMate: $isMate, selectedMoveIndex: $selectedMoveIndex, flipped: $flipped)
                            .frame(width: size, height: size)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedPiece = nil
                                legalMoves = []
                                legalCaptures = []
                                selectedPosition = nil
                            }
                    }
                    HStack(spacing: 0) {
                        CapturedPiecesView(capturedPieces: board.capturedPieces.getBlackCapturedPieces())
                        Spacer()
                        if let pointDifference = pointDifference(), pointDifference < 0 {
                            Text("+\(-pointDifference)")
                                .foregroundColor(Color.black.opacity(0.5))
                                .padding(.leading, 5)
                        }
                    }
                    .frame(height: 30)
                    .padding(.horizontal, 10)
                    
                    PVPMoveLogView(board: board)
                        .frame(width: 230, height: 200)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                        .padding(.trailing, 20)
                        .padding(.leading, 20)
                }
            }
        }
        .onReceive(countdownTimer) { _ in
            guard matchManager.isTimeKeeper else { return }
            if matchManager.currentTurn {
                matchManager.remainingTimeWhite -= 1
            } else {
                matchManager.remainingTimeBlack -= 1
            }
        }
        .onReceive(matchManager.$lastReceivedMove) { move in
            if let move = move {
                // Update the board and UI when a new move is received
                self.board.applyMove(from: (move.oldRow, move.oldCol), to: (move.newRow, move.newCol), isPromotion: move.isPromotion, pieceType: move.pieceType)
            }
        }
    }
    
    var topBar: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer().frame(width: 20)
                    Button {
                        matchManager.match?.disconnect()
                        matchManager.resetGame()
                    } label: {
                        Image(systemName: "arrowshape.turn.up.left.circle.fill")
                            .font(.largeTitle)
                            .tint(Color.red)
                    }
                    Spacer()
                    if matchManager.currentTurn {
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
                            Image("white-pawn")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 34, height: 34)
                        }
                    }
                    Spacer()
                    
                    Label("\(matchManager.remainingTimeWhite)",
                          systemImage: "clock.fill")
                    .bold()
                    .font(.title2)
                    .foregroundColor(Color.red)
                    Spacer().frame(width: 20)
                }
                HStack(spacing: 0) {
                    Spacer().frame(width: 60)
                    Spacer()
                    if !matchManager.currentTurn {
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
                    
                    Label("\(matchManager.remainingTimeWhite)",
                          systemImage: "clock.fill")
                    .bold()
                    .font(.title2)
                    .foregroundColor(Color.red)
                    Spacer().frame(width: 20)
                }
            }
        }
        .padding(.vertical, 15)
    }
    
    private func pointDifference() -> Int? {
        let whitePoints = board.capturedPieces.calculateWhitePoints()
        let blackPoints = board.capturedPieces.calculateBlackPoints()
        return whitePoints - blackPoints
    }
}

struct PiecesView: View {
    @ObservedObject var board: Board
    @ObservedObject var matchManager: MatchManager
    var squareSize: CGFloat
    @Binding var selectedPiece: GamePiece?
    @Binding var legalMoves: [(Int, Int)]
    @Binding var legalCaptures: [(Int, Int)]
    @Binding var selectedPosition: (Int, Int)?
    @Binding var whiteMove: Bool
    @Binding var isMate: Bool
    @Binding var selectedMoveIndex: Int?
    @Binding var flipped: Bool

    @State private var isPieceSelected = false
    @State private var dragOffset = CGSize.zero
    @State private var draggedPiece: GamePiece?
    @State private var initialPosition: (Int, Int)?
    @State private var enPassantPosition: (Int, Int)?
    @State private var glowOpacity = 0.3
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    let checkFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        if let lastMove = board.getMoveLog().last {
            if lastMove.isCheck == true {
                let color = lastMove.piece.color
                ZStack {
                    let (kingRow, kingCol) = self.board.getKingPosition(color: color == "black" ? "white" : "black")
                    let (displayRow, displayCol) = flipped ? (7 - kingRow, 7 - kingCol) : (kingRow, kingCol)
                    RadialGradient(colors: [.red, .clear], center: .center, startRadius: 10, endRadius: 30)
                        .frame(width: squareSize, height: squareSize)
                        .position(x: CGFloat(displayCol) * (squareSize) + (squareSize / 2) * 1.43, y: CGFloat(displayRow) * (squareSize) + (squareSize / 2) * 1.44)
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
                        let displayRow = flipped ? 7 - row : row
                        let displayCol = flipped ? 7 - col : col
                        ZStack {
                            if let ep = enPassantPosition, ep == (displayRow, displayCol) {
                                RadialGradient(colors: [.red, .red], center: .center, startRadius: 15, endRadius: 30)
                                    .position(x: CGFloat(squareSize * 0.5), y: CGFloat(squareSize * 0.5))
                                
                            }
                            if legalMoves.contains(where: { $0 == (displayRow, displayCol)}) {
                                if legalCaptures.contains(where: { $0 == (displayRow, displayCol) }) {
                                    RadialGradient(colors: [.red, .red], center: .center, startRadius: 15, endRadius: 30)
                                        .position(x: CGFloat(squareSize * 0.5), y: CGFloat(squareSize * 0.5))
                                        .onTapGesture {
                                            feedbackGenerator.impactOccurred()
                                            movePiece(to: (displayRow, displayCol))
                                        }
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.9))
                                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 2, y: 2)
                                        .frame(width: squareSize * 0.4, height: squareSize * 0.4)
                                        .onTapGesture {
                                            feedbackGenerator.impactOccurred()
                                            movePiece(to: (displayRow, displayCol))
                                        }
                                }
                            }
                            if let piece = board.getPiece(row: displayRow, col: displayCol) {
                                Image(uiImage: piece.img!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: squareSize, height: squareSize)
                                    .scaledToFit()
                                    .scaleEffect(isSelectedPosition(row: displayRow, col: displayCol) ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: isPieceSelected)
                                    .shadow(color: Color.black.opacity(0.4), radius: 2, x: 1, y: 1)
                                    .offset(
                                        x: selectedPiece == piece ? dragOffset.width : 0,
                                        y: selectedPiece == piece ? dragOffset.height : 0
                                    )

                                    .rotationEffect(isMate && piece.pieceType == "king" && (piece.color == "white" && whiteMove || piece.color == "black" && !whiteMove) ? .degrees(-90) : .degrees(0))
                                    .onTapGesture {
                                        feedbackGenerator.impactOccurred()
                                        if legalCaptures.contains(where: { $0 == (displayRow, displayCol) }) {
                                            movePiece(to: (displayRow, displayCol))
                                        } else {
                                            selectPiece(piece: piece, at: (displayRow, displayCol))
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
        } else {
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
        if matchManager.currentTurn && ((whiteMove && piece.color == "white") || (!whiteMove && piece.color == "black")) {
                selectedPiece = piece
                selectedPosition = position
                piece.setLegalMoves(board: self.board)
                legalMoves = piece.validateLegalMoves(board: self.board)
                legalCaptures = piece.getLegalCaptures(board: self.board)
                isPieceSelected = true
                getEnPassantPosition()
            } else {
                selectedPiece = nil
                legalMoves = []
                legalCaptures = []
                selectedPosition = nil
                enPassantPosition = nil
            }
        }

        private func movePiece(to newPos: (Int, Int)) {
            guard let piece = selectedPiece, let currentPosition = selectedPosition else { return }
            
            let rowDiff = CGFloat(newPos.0 - currentPosition.0) * squareSize
            let colDiff = CGFloat(newPos.1 - currentPosition.1) * squareSize

            dragOffset = CGSize(width: -colDiff, height: -rowDiff)

            board.movePiece(piece: piece, newPosition: newPos)
            
            withAnimation(Animation.interpolatingSpring(stiffness: 140, damping: 25, initialVelocity: 15)) {
                dragOffset = .zero
            }
            board.undoneMoves.reset()
            
            selectedMoveIndex = board.getMoveLog().count - 1
            isMate = board.getMoveLog().last?.isCheckmate == true ? true : false
            
            whiteMove.toggle()
            selectedPiece = nil
            selectedPosition = nil
            legalMoves = []
            legalCaptures = []
            isPieceSelected = false
            enPassantPosition = nil
        }
}

#Preview {
    GameView(matchManager: MatchManager())
}
