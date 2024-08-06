
import SwiftUI

struct ChessPiecesView: View {
    @ObservedObject var board: Board
    var squareSize: CGFloat
    @Binding var selectedPiece: GamePiece?
    @Binding var legalMoves: Set<Position>
    @Binding var legalCaptures: Set<Position>
    @Binding var selectedPosition: Position?
    @Binding var whiteMove: Bool
    @Binding var isMate: Bool
    @Binding var selectedMoveIndex: Int?
    @Binding var lastMovedPiece: GamePiece?
    @Binding var lastMoveOriginal: Position?
    @Binding var lastMoveNew: Position?
    @State private var isPieceSelected = false
    @State private var dragOffset = CGSize.zero
    @State private var draggedPiece: GamePiece?
    @State private var dragPosition: CGPoint = .zero
    @State private var initialPosition: Position?
    @State private var enPassantPosition: Position?
    @State private var glowOpacity = 0.3

    
    var flipped: Bool
    let feedbackGeneratorSelect = UIImpactFeedbackGenerator(style: .light)
    let feedbackGeneratorMove = UIImpactFeedbackGenerator(style: .medium)
    let feedbackGeneratorCheck = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        if let lastMove = board.getMoveLog().last {
            if lastMove.isCheck == true {
                ZStack {
                    let (kingRow, kingCol) = self.board.getKingPosition(color: whiteMove ? "white" : "black").destructure()
                    let (displayRow, displayCol) = flipped ? (7 - kingRow, 7 - kingCol) : (kingRow, kingCol)
                    RadialGradient(colors: [.red, .clear], center: .center, startRadius: 10, endRadius: 30)
                        .frame(width: squareSize, height: squareSize)
                        .position(x: CGFloat(displayCol) * (squareSize) + (squareSize / 2) * 1.43, y: CGFloat(displayRow) * (squareSize) + (squareSize / 2) * 1.44)
                        .opacity(glowOpacity)
                        .onAppear {
                            withAnimation(Animation.bouncy(duration: 1).repeatForever(autoreverses: true)) {
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
                        let position = Position(x: displayRow, y: displayCol)
                            ZStack {
                                if let ep = enPassantPosition, ep == position {
                                    RadialGradient(colors: [.red, .red], center: .center, startRadius: 15, endRadius: 30)
                                        .position(x: CGFloat(squareSize * 0.5), y: CGFloat(squareSize * 0.5))
                                    
                                }
                                if legalMoves.contains(where: { $0 == position}) {
                                    if legalCaptures.contains(where: { $0 == position }) {
                                        RadialGradient(colors: [.red, .red], center: .center, startRadius: 15, endRadius: 30)
                                            .position(x: CGFloat(squareSize * 0.5), y: CGFloat(squareSize * 0.5))
                                            .onTapGesture {
                                                movePiece(to: position)
                                            }
                                    } else {
                                        Circle()
                                            .fill(Color.blue.opacity(0.5))
                                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 2, y: 2)
                                            .frame(width: squareSize * 0.3, height: squareSize * 0.3)
                                            .onTapGesture {
                                                movePiece(to: position)
                                            }
                                    }
                                }
                                if let piece = board.getPiece(position: position) {
                                    Image(uiImage: piece.img!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: squareSize, height: squareSize)
                                        .scaledToFit()
                                        .scaleEffect(isSelectedPosition(position: position) ? 1.2 : 1.0)
                                        .animation(.easeInOut(duration: 0.2), value: isPieceSelected)
                                        .shadow(color: Color.black.opacity(0.4), radius: 2, x: 1, y: 1)
                                        .offset(
                                            x: selectedPiece == piece ? dragOffset.width : 0,
                                            y: selectedPiece == piece ? dragOffset.height : 0
                                        )
                                    
                                        .rotationEffect(isMate && piece.pieceType == "king" && (piece.color == "white" && whiteMove || piece.color == "black" && !whiteMove) ? .degrees(-90) : .degrees(0))
                                    
                                        .onTapGesture {
                                            if legalCaptures.contains(where: { $0 == position }) {
                                                movePiece(to: position)
                                                
                                            } else {
                                                selectPiece(piece: piece, at: position)
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
                            .onChange(of: isMate) {
                                feedbackGeneratorCheck.impactOccurred(intensity: 1.0)
                            }
                            .onChange(of: whiteMove) {
                                feedbackGeneratorMove.impactOccurred(intensity: 1.0)
                            }
                            .onChange(of: selectedMoveIndex) { newValue, _ in
                                if let selectedMoveIndex = selectedMoveIndex {
//                                     .indices.contains(selectedMoveIndex)
                                    let move = board.getMoveLog()[selectedMoveIndex]
                                    lastMoveOriginal = move.oldPosition
                                    lastMoveNew = move.newPosition
                                }
                            }
                    }
                }
                
            }
        }
    }

//    guard let movelog = board.getMoveLog().last else { return AnyView(EmptyView()) }
//        
//        let originalPosition = movelog.oldPosition
//        let newPosition = movelog.newPosition
//        
//        let startHighlight = RadialGradient(colors: [.blue, .blue], center: .center, startRadius: 15, endRadius: 30)
//            .position(x: CGFloat(originalPosition.y) * squareSize + squareSize / 2, y: CGFloat(originalPosition.x) * squareSize + squareSize / 2)
//            .opacity(0.3)
//        
//        let endHighlight = RadialGradient(colors: [.red, .red], center: .center, startRadius: 15, endRadius: 30)
//            .position(x: CGFloat(newPosition.y) * squareSize + squareSize / 2, y: CGFloat(newPosition.x) * squareSize + squareSize / 2)
//            .opacity(0.6)

    private func getEnPassantPosition() {
        if let selectedPiece = selectedPiece as? Pawn, selectedPiece.isEnPassant {
            enPassantPosition = Position(x: selectedPiece.enPassantPosition.x, y: selectedPiece.enPassantPosition.y)
        }
        else {
            enPassantPosition = nil
        }
    }
    
    private func isSelectedPosition(position: Position) -> Bool {
        if let selectedPosition = selectedPosition {
            return selectedPosition == position
        }
        return false
    }
    
    private func selectPiece(piece: GamePiece, at position: Position) {
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

    private func movePiece(to newPos: Position) {
        guard let piece = selectedPiece, let currentPosition = selectedPosition else { return }
        
        let rowDiff = CGFloat(newPos.x - currentPosition.x) * squareSize
        let colDiff = CGFloat(newPos.y - currentPosition.y) * squareSize
        
        if flipped {
            dragOffset = CGSize(width: colDiff, height: rowDiff)
        } else {
            dragOffset = CGSize(width: -colDiff, height: -rowDiff)
        }
        
        if piece.pieceType == "king" && abs(newPos.y - currentPosition.y) == 2 {
            board.movePiece(piece: piece, newPosition: newPos)
//            if flipped {
                dragOffset = CGSize(width: colDiff, height: rowDiff)
//            } else {
//                dragOffset = CGSize(width: -colDiff, height: -rowDiff)
//            }
            withAnimation(.easeInOut(duration: 3.0)) {
                dragOffset = .zero
            }
        } else {
            board.movePiece(piece: piece, newPosition: newPos)
            
            withAnimation(Animation.interpolatingSpring(stiffness: 140, damping: 25, initialVelocity: 15)) {
                dragOffset = .zero
            }
        }
//        board.undoneMoves.reset()
        

        selectedMoveIndex = board.getMoveLog().count - 1
        isMate = board.getMoveLog().last!.isCheckmate == true ? true : false
        lastMovedPiece = board.getMoveLog().last!.piece
        
        whiteMove = board.whiteTurn
        selectedPiece = nil
        selectedPosition = nil
        legalMoves = []
        legalCaptures = []
        isPieceSelected = false
        enPassantPosition = nil
    }
}
