
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
    @State private var dragPosition: CGPoint = .zero
    @State private var initialPosition: (Int, Int)?
    @State private var enPassantPosition: (Int, Int)?
    @State private var glowOpacity = 0.3
    var flipped: Bool
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    let checkFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        if let lastMove = board.getMoveLog().last {
            if lastMove.isCheck == true {
                ZStack {
                    let (kingRow, kingCol) = self.board.getKingPosition(color: whiteMove ? "white" : "black")
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
                                        .fill(Color.blue.opacity(0.5))
                                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 2, y: 2)
                                        .frame(width: squareSize * 0.3, height: squareSize * 0.3)
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
