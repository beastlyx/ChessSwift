////
////  DrawingView.swift
////  Guess The Doodle
////
////  Created by Borys Banaszkiewicz on 8/3/24.
////
//
//import SwiftUI
//import PencilKit
//
//struct DrawingView: UIViewRepresentable {
//    class Coordinator: NSObject, PKCanvasViewDelegate {
//        var matchManager: MatchManager
//        
//        init(matchManager: MatchManager) {
//            self.matchManager = matchManager
//        }
//        
//        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//            guard canvasView.isUserInteractionEnabled else { return }
//            matchManager.sendData(canvasView.drawing.dataRepresentation(), mode: .reliable)
//        }
//    }
//    
//    @ObservedObject var matchManager: MatchManager
//    @Binding var eraserEnabled: Bool
//    
//    func makeUIView(context: Context) -> PKCanvasView {
//        let canvasView = PKCanvasView()
//        
//        canvasView.drawingPolicy = .anyInput
//        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
//        canvasView.delegate = context.coordinator
//        canvasView.isUserInteractionEnabled = matchManager.currentlyDrawing
//        
//        return canvasView
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(matchManager: matchManager)
//    }
//    
//    func updateUIView(_ uiView: PKCanvasView, context: Context) {
//        let wasDrawing = uiView.isUserInteractionEnabled
//        uiView.isUserInteractionEnabled = matchManager.currentlyDrawing
//        
//        if !wasDrawing && matchManager.currentlyDrawing {
//            uiView.drawing = PKDrawing()
//        }
//        
//        if !uiView.isUserInteractionEnabled || !matchManager.inGame {
//            uiView.drawing = matchManager.lastReceivedDrawing
//        }
//        
//        uiView.tool = eraserEnabled ? PKEraserTool(.vector) : PKInkingTool(.pen, color: .black, width: 5)
//    }
//}
//
//struct DrawingView_Previews: PreviewProvider {
//    @State static var eraser = false
//    static var previews: some View {
//        DrawingView(matchManager: MatchManager(), eraserEnabled: $eraser)
//    }
//}

import SwiftUI

struct ChessGameView: UIViewControllerRepresentable {
    
    class Coordinator: NSObject {
        var matchManager: MatchManager
        
        init(matchManager: MatchManager) {
            self.matchManager = matchManager
        }

//        func sendMove(_ move: MoveData) {
//            let moveString = "(\(move.originalPosition.0),\(move.originalPosition.1)):(\(move.newPosition.0),\(move.newPosition.1)):\(move.isPromotion):\(move.pieceType)"
//            guard let moveData = "strData:\(moveString)".data(using: .utf8) else { return }
//            matchManager.sendData(moveData, mode: .reliable)
//        }
    }
    
    @ObservedObject var matchManager: MatchManager
    @Binding var moveMade: String
    
    func makeUIViewController(context: Context) -> UIHostingController<ChessView> {
        let chessView = ChessView(matchManager: matchManager, coordinator: context.coordinator, moveMade: $moveMade)
        return UIHostingController(rootView: chessView)
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<ChessView>, context: Context) {
        uiViewController.rootView = ChessView(matchManager: matchManager, coordinator: context.coordinator, moveMade: $moveMade)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(matchManager: matchManager)
    }
}

struct ChessView: View {
    @ObservedObject var matchManager: MatchManager
    var coordinator: ChessGameView.Coordinator
    @Binding var moveMade: String
    @ObservedObject var board = Board()
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
    @State private var flipped = false

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height * 0.7)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    CapturedPiecesView(capturedPieces: board.capturedPieces.getWhiteCapturedPieces())
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
                    let squareSize = size / 8
                    ChessBorderView(squareSize: squareSize, color1: lightSquareColor, color2: darkSquareColor, flipped: flipped)
                        .frame(width: size, height: size)

                    PiecesView(board: board, squareSize: squareSize * 0.95, selectedPiece: $selectedPiece, legalMoves: $legalMoves, legalCaptures: $legalCaptures, selectedPosition: $selectedPosition, whiteMove: $whiteMove, isMate: $isMate, selectedMoveIndex: $selectedMoveIndex, moveMade: $moveMade, flipped: flipped)
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
                .frame(height: 50)
                .padding(.horizontal, 10)
                
                moveLog
                    .frame(width: 230, height: 200)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                    .padding(.trailing, 20)
                    .padding(.leading, 20)

            }
            if showingPromotionDialog, let details = promotionDetails {
                PromotionDialogOverlayView(details: details, size: size, onSelect: { piece in
                    details.3(piece)
                    showingPromotionDialog = false
                })
            }
        }
        .background(Color.white)
        .onChange(of: matchManager.lastReceivedMove) { newMove in
            guard newMove.originalPosition != (-1, -1) else { return }
            board.applyMove(from: newMove.originalPosition, to: newMove.newPosition, isPromotion: newMove.isPromotion, pieceType: newMove.pieceType)
            selectedPiece = nil
            legalMoves = []
            legalCaptures = []
            selectedPosition = nil
            whiteMove.toggle()
        }
    }

    private func pointDifference() -> Int? {
        let whitePoints = board.capturedPieces.calculateWhitePoints()
        let blackPoints = board.capturedPieces.calculateBlackPoints()
        return whitePoints - blackPoints
    }

    private func reset() {
        board.reset()
        selectedPiece = nil
        legalMoves = []
        legalCaptures = []
        selectedPosition = nil
        whiteMove = true
        isMate = false
        selectedMoveIndex = nil
    }
    
    var moveLog: some View {
        let moves = board.getMoveLog()
        return ScrollView {
            Spacer().frame(width: 1, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                ForEach(0..<((moves.count / 2) + 1), id: \.self) { index in
                    HStack(spacing: 0) {
                        Text("\(index + 1).")
                            .frame(width: 25, alignment: .leading)
                            .font(.system(size: 14))
                            .foregroundColor(Color.black.opacity(0.1))  // Apply transparency to the number
                            .fixedSize(horizontal: true, vertical: false)
                        if index * 2 < moves.count {
                            let moveIndex = index * 2
                            HStack(spacing: 0) {
                                Image(uiImage: moves[moveIndex].piece.img!)
                                    .resizable()
                                    .frame(width: 17, height: 17, alignment: .trailing)
                                Text(moves[moveIndex].move)
                                    .frame(width: 60, alignment: .leading)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.black.opacity(0.4))  // Apply transparency to the move
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                        }
                        if index * 2 + 1 < moves.count {
                            let moveIndex = index * 2 + 1
                            HStack(spacing: 0) {
                                Spacer().frame(width: 30)
                            Image(uiImage: moves[moveIndex].piece.img!)
                                .resizable()
                                .frame(width: 17, height: 17, alignment: .leading)
                            Text(moves[moveIndex].move)
                                .frame(width: 60, alignment: .leading)
                                .font(.system(size: 14))
                                .foregroundColor(Color.black.opacity(0.4))  // Apply transparency to the move
                                .fixedSize(horizontal: true, vertical: false)
                            }
                        }
                    }
                    Divider()
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.horizontal, 10)
        }
    }
}

struct ChessGameView_Previews: PreviewProvider {
    static var previews: some View {
        ChessGameView(matchManager: MatchManager(), moveMade: .constant(""))
    }
}
