//
//  PlayerVersusPlayerView.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 8/1/24.
//

import SwiftUI

struct PlayerVersusPlayerView: View {
    @StateObject private var chessServer = ChessServer()
    @StateObject private var chessClient1 = ChessClient(flipped: false, isWhite: true)
    @StateObject private var chessClient2 = ChessClient(flipped: true, isWhite: false)

    var body: some View {
        VStack {
            ServerView(chessServer: chessServer)
            Divider()
            HStack {
                ClientView(chessClient: chessClient1, flipped: $chessClient1.flipped, isWhite: $chessClient1.isWhite)
                Divider()
                ClientView(chessClient: chessClient2, flipped: $chessClient2.flipped, isWhite: $chessClient2.isWhite)
            }
        }
        .padding()
        .onAppear {
            chessServer.startListening()
            chessClient1.connectToServer()
            chessClient2.connectToServer()
        }
        .onChange(of: chessServer.currentTurn) { newTurn in
            chessClient1.isClientTurn.toggle()
            chessClient2.isClientTurn.toggle()
        }
    }
}

struct ServerView: View {
    @ObservedObject var chessServer: ChessServer

    var body: some View {
        VStack(alignment: .leading) {
            Text(chessServer.isListening ? "Server is Listening" : "Server Stopped")
            Button(chessServer.isListening ? "Stop Server" : "Start Server") {
                if chessServer.isListening {
                    chessServer.stopListening()
                } else {
                    chessServer.startListening()
                }
            }
            ScrollView {
                ForEach(chessServer.statusMessages, id: \.self) { message in
                    Text(message)
                        .padding(.bottom, 2)
                        .frame(alignment: .leading)
                        .font(.system(size: 16).bold())
                        .foregroundColor(Color.black)
                    Divider()
                }
            }
            .frame(alignment: .leading)
        }
        .padding()
        .frame(width: 400, alignment: .leading)
        .background(Color.gray.opacity(0.5))
        .cornerRadius(10)
    }
}

struct ClientView: View {
    @ObservedObject var chessClient: ChessClient
    @State private var selectedPiece: GamePiece?
    @State private var legalMoves: [(Int, Int)] = []
    @State private var legalCaptures: [(Int, Int)] = []
    @State private var selectedPosition: (Int, Int)?
    @State private var isMate: Bool = false
    @Binding var flipped: Bool
    @Binding var isWhite: Bool
    @State private var selectedMoveIndex: Int? = nil
    @State private var showingPromotionDialog = false
    @State private var promotionDetails: (Int, Int, String, (GamePiece) -> Void)?
    
    var body: some View {
        VStack {
            Text("Client UUID: \(chessClient.uuidString)")
            if chessClient.isConnected {
                Text("Connected to Server")
            } else {
                Text("Not Connected")
                Button("Connect to Server") {
                    chessClient.connectToServer()
                }
            }
            
            HStack(spacing: 0) {
                CapturedPiecesView(capturedPieces: chessClient.board.capturedPieces.getWhiteCapturedPieces())
                Spacer()
                if let pointDifference = pointDifference(), pointDifference > 0 {
                    Text("+\(pointDifference)")
                        .foregroundColor(Color.black.opacity(0.5))
                        .padding(.leading, 5)
                }
            }
            .frame(height: 50)
            .padding(.horizontal, 10)
            ZStack {
                let size = CGFloat(400)
                ChessBorderView(squareSize: size / 8, color1: .white, color2: Color(red: 218/255, green: 140/255, blue: 44/255), flipped: flipped)
                NewChessPiecesView(board: chessClient.board, squareSize: (size * 0.95) / 8, selectedPiece: $selectedPiece, legalMoves: $legalMoves, legalCaptures: $legalCaptures, selectedPosition: $selectedPosition, whiteMove: $isWhite, isMate: $isMate, selectedMoveIndex: $selectedMoveIndex, isClientTurn: $chessClient.isClientTurn, flipped: $flipped, movePieceCallback: { oldRow, oldCol, newRow, newCol, isPromotion, pieceType in
                    if chessClient.isClientTurn {
                        chessClient.sendMove(oldRow: oldRow, oldCol: oldCol, newRow: newRow, newCol: newCol, isPromotion: isPromotion, pieceType: pieceType)
                    }
                })
            }
            .frame(width: CGFloat(400), height: CGFloat(400))
            HStack(spacing: 0) {
                CapturedPiecesView(capturedPieces: chessClient.board.capturedPieces.getBlackCapturedPieces())
                Spacer()
                if let pointDifference = pointDifference(), pointDifference < 0 {
                    Text("+\(-pointDifference)")
                        .foregroundColor(Color.black.opacity(0.5))
                        .padding(.leading, 5)
                }
            }
            .frame(height: 50)
            .padding(.horizontal, 10)
            
            PVPMoveLogView(board: chessClient.board)
                .frame(width: 230, height: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.bottom, 20)
                .padding(.trailing, 20)
                .padding(.leading, 20)
            
                .onReceive(chessClient.board.promotionPublisher) { details in
                    if chessClient.isClientTurn { // Check if it's the client's turn
                        promotionDetails = details
                        showingPromotionDialog = true
                    }
                }
        }
        .padding()
        if chessClient.isClientTurn && showingPromotionDialog, let details = promotionDetails {
            PromotionDialogOverlayView(details: details, size: CGFloat(400), onSelect: { piece in
                details.3(piece)
                showingPromotionDialog = false
            })
        }
    }
    
    private func pointDifference() -> Int? {
        let whitePoints = chessClient.board.capturedPieces.calculateWhitePoints()
        let blackPoints = chessClient.board.capturedPieces.calculateBlackPoints()
        return whitePoints - blackPoints
    }
    
//    private func reset() {
//        chessClient.board.reset()
//        selectedPiece = nil
//        legalMoves = []
//        legalCaptures = []
//        selectedPosition = nil
//        whiteMove = true
//        isMate = false
//        selectedMoveIndex = nil
//    }
}


struct NewChessPiecesView: View {
    @ObservedObject var board: Board
    var squareSize: CGFloat
    @Binding var selectedPiece: GamePiece?
    @Binding var legalMoves: [(Int, Int)]
    @Binding var legalCaptures: [(Int, Int)]
    @Binding var selectedPosition: (Int, Int)?
    @Binding var whiteMove: Bool
    @Binding var isMate: Bool
    @Binding var selectedMoveIndex: Int?
    @Binding var isClientTurn: Bool
    @Binding var flipped: Bool

    @State private var isPieceSelected = false
    @State private var dragOffset = CGSize.zero
    @State private var draggedPiece: GamePiece?
    @State private var initialPosition: (Int, Int)?
    @State private var enPassantPosition: (Int, Int)?
    @State private var glowOpacity = 0.3
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    let checkFeedback = UIImpactFeedbackGenerator(style: .heavy)

    var movePieceCallback: (Int, Int, Int, Int, Bool, String) -> Void
    
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
//                                    .opacity(0.8)
                                
                            }
                            if legalMoves.contains(where: { $0 == (displayRow, displayCol)}) {
                                if legalCaptures.contains(where: { $0 == (displayRow, displayCol) }) {
                                    RadialGradient(colors: [.red, .red], center: .center, startRadius: 15, endRadius: 30)
                                        .position(x: CGFloat(squareSize * 0.5), y: CGFloat(squareSize * 0.5))
//                                        .opacity(0.8)
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
        if isClientTurn && ((whiteMove && piece.color == "white") || (!whiteMove && piece.color == "black")) {
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
            guard let piece = selectedPiece, let oldPos = selectedPosition else { return }

            board.movePiece(piece: piece, newPosition: newPos)
            
            isMate = board.getMoveLog().last?.isCheckmate == true ? true : false
            
//            whiteMove.toggle()
//            isClientTurn.toggle()
            selectedPiece = nil
            selectedPosition = nil
            legalMoves = []
            legalCaptures = []
            isPieceSelected = false
            dragOffset = .zero
            draggedPiece = nil
            enPassantPosition = nil
            
            let last = board.getMoveLog().last
            
            movePieceCallback(oldPos.0, oldPos.1, newPos.0, newPos.1, last?.isPromotion ?? false, last?.piece.pieceType ?? "")
        }
}

#Preview {
    PlayerVersusPlayerView()
}


