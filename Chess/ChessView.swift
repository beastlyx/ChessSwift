import SwiftUI

struct ChessView: View {
    @ObservedObject var matchManager: MatchManager
    @ObservedObject var board: Board
    @State private var selectedPiece: GamePiece?
    @State private var legalMoves: [(Int, Int)] = []
    @State private var legalCaptures: [(Int, Int)] = []
    @State private var selectedPosition: (Int, Int)?
    @State private var whiteMove = true
    @State private var isMate: Bool = false
    @State private var selectedMoveIndex: Int? = nil
    @State private var lightSquareColor: Color = UserDefaults.standard.color(forKey: "lightSquareColor") ?? .white
    @State private var darkSquareColor: Color = UserDefaults.standard.color(forKey: "darkSquareColor") ?? Color(red: 218/255, green: 140/255, blue: 44/255)
    @State private var flipped = false
    
    var isWhite: Bool
    var currentlyMoving: Bool
    var onMoveMade: (MoveData) -> Void
    
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

                    PiecesView(board: board, squareSize: squareSize * 0.95, selectedPiece: $selectedPiece, legalMoves: $legalMoves, legalCaptures: $legalCaptures, selectedPosition: $selectedPosition, whiteMove: $whiteMove, isMate: $isMate, selectedMoveIndex: $selectedMoveIndex, onMoveMade: onMoveMade, flipped: flipped, isWhite: isWhite, currentlyMoving: currentlyMoving)
                        .frame(width: size, height: size)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPiece = nil
                            legalMoves = []
                            legalCaptures = []
                            selectedPosition = nil
                        }
                        .onChange(of: matchManager.lastReceivedMove) { newMove in
                            applyMove(newMove)
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
                    .background(Color.gray.opacity(0.6))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                    .padding(.trailing, 20)
                    .padding(.leading, 20)

            }


        }

        .background(
        Image("gameBg")
            .resizable()
            .scaledToFit()
            .scaleEffect(1.6)
            .opacity(0.4)
        )
        .ignoresSafeArea()
        .onAppear {
            self.flipped = !isWhite
        }
        
    }
    
    private func applyMove(_ move: MoveData) {
        let originalPosition = (move.originalPosition.x, move.originalPosition.y)
        let newPosition = (move.newPosition.x, move.newPosition.y)
        self.board.applyMove(from: originalPosition, to: newPosition, isPromotion: move.isPromotion, pieceType: move.pieceType)
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
