import SwiftUI
import Combine

struct GameResult: Identifiable {
    var id = UUID()
    var message: String
}

struct ExplorerView: View {
    @ObservedObject private var board = Board()
    @State private var selectedPiece: GamePiece?
    @State private var legalMoves: Set<Position> = Set()
    @State private var legalCaptures: Set<Position> = Set()
    @State private var selectedPosition: Position?
    @State private var whiteMove = true
    @State private var isMate: Bool = false
    @State private var selectedMoveIndex: Int? = nil
    @State private var showingPromotionDialog = false
    @State private var promotionDetails: (Position, String, (GamePiece) -> Void)?
    @State private var lightSquareColor: Color = UserDefaults.standard.color(forKey: "lightSquareColor") ?? .white
    @State private var darkSquareColor: Color = UserDefaults.standard.color(forKey: "darkSquareColor") ?? Color(red: 218/255, green: 140/255, blue: 44/255)
    @State private var showingEditBoardView = false
    @State private var flipped = false
    @State private var toggleSwitch = false
    @State private var lastMovedPiece: GamePiece?
    @State private var lastMoveOriginal: Position?
    @State private var lastMoveNew: Position?
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height * 0.7)
                VStack(spacing: 0) {
                    SideMenuView(showingEditBoardView: $showingEditBoardView)
                    HStack(spacing: 0) {
                        CapturedPiecesView(capturedPieces: board.capturedPiecesWhite)
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
                        ChessBorderView(squareSize: squareSize, color1: lightSquareColor, color2: darkSquareColor, flipped: flipped, lastMoveOriginal: $lastMoveOriginal, lastMoveNew: $lastMoveNew)
                            .frame(width: size, height: size)
                       
                        ChessPiecesView(board: board, squareSize: squareSize * 0.95, selectedPiece: $selectedPiece, legalMoves: $legalMoves, legalCaptures: $legalCaptures, selectedPosition: $selectedPosition, whiteMove: $whiteMove, isMate: $isMate, selectedMoveIndex: $selectedMoveIndex, lastMovedPiece: $lastMovedPiece, lastMoveOriginal: $lastMoveOriginal, lastMoveNew: $lastMoveNew, flipped: flipped)
                            .frame(width: size, height: size)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedPiece = nil
                                legalMoves = []
                                legalCaptures = []
                                selectedPosition = nil
                            }
                            .onReceive(board.promotionPublisher) { details in
                                self.promotionDetails = details
                                self.showingPromotionDialog = true
                            }
                    }
                    HStack(spacing: 0) {
                        CapturedPiecesView(capturedPieces: board.capturedPiecesBlack)
                        Spacer()
                        if let pointDifference = pointDifference(), pointDifference < 0 {
                            Text("+\(-pointDifference)")
                                .foregroundColor(Color.black.opacity(0.5))
                                .padding(.leading, 5)
                        }
                    }
                    .frame(height: 50)
                    .padding(.horizontal, 10)
                    HStack(spacing: 0) {
                        VStack(spacing: 0) {
                            HStack(spacing: 10) {
                                Button(action: {
                                    undoMove()
                                }) {
                                    Image(systemName: "arrowshape.left.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(Color.red)
                                }
                                Button(action: {
                                    redoMove()
                                }) {
                                    Image(systemName: "arrowshape.right.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(Color.red)
                                }
                            }
                            Spacer().frame(height: geometry.size.height * 0.05)
                            
                            Button(action: {
                                reset()
                            }) {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(Color.red)
                            }
                        }
                        MoveLogView(board: board, selectedMoveIndex: $selectedMoveIndex, whiteMove: $whiteMove, isMate: $isMate)
                            .frame(width: 230, height: 200)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.bottom, 20)
                            .padding(.trailing, 20)
                            .padding(.leading, 20)
                    }
                    .padding(.top, 10)
                }
                if showingPromotionDialog, let details = promotionDetails {
                    PromotionDialogOverlayView(details: details, size: size, onSelect: { piece in
                        details.2(piece)
                        showingPromotionDialog = false
                    })
                }
            }
            .background(Color.white)
            
            .sheet(isPresented: $showingEditBoardView) {
                EditBoardView(lightSquareColor: $lightSquareColor, darkSquareColor: $darkSquareColor, toggleSwitch: $toggleSwitch, flipped: $flipped)
            }
            .onChange(of: lightSquareColor) { newColor, _ in
                UserDefaults.standard.set(newColor, forKey: "lightSquareColor")
            }
            .onChange(of: darkSquareColor) { newColor, _ in
                UserDefaults.standard.set(newColor, forKey: "darkSquareColor")
            }
        }
    }
    
    private func pointDifference() -> Int? {
        let whitePoints = board.calculateWhitePoints()
        let blackPoints = board.calculateBlackPoints()
        return whitePoints - blackPoints
    }
    
    private func undoMove() {
        guard let index = selectedMoveIndex, index > 0 else { return }
        
        selectedMoveIndex = index - 1
        board.setMove(index: selectedMoveIndex!)
        
        lastMovedPiece = board.getMoveLog().last?.piece
        
        selectedPiece = nil
        legalMoves = []
        legalCaptures = []
        whiteMove.toggle()
        isMate = board.getMoveLog().last?.isCheckmate == true ? true : false
    }
    
    private func redoMove() {
        guard let index = selectedMoveIndex, index < self.board.getMoveLog().count - 1 else { return }
        
        selectedMoveIndex = index + 1
        board.setMove(index: selectedMoveIndex!)
        lastMovedPiece = board.getMoveLog().last?.piece
        
        selectedPiece = nil
        legalMoves = []
        legalCaptures = []
        whiteMove.toggle()
        isMate = board.getMoveLog().last?.isCheckmate == true ? true : false
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
        lastMovedPiece = nil
        lastMoveOriginal = nil
        lastMoveNew = nil
    }
}

#Preview {
    ExplorerView()
}
