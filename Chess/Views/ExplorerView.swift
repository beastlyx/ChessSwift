import SwiftUI
import Combine

struct GameResult: Identifiable {
    var id = UUID()
    var message: String
}

struct ExplorerView: View {
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
    
    var body: some View {
        NavigationStack {
            
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height * 0.7)
                VStack(spacing: 0) {
                    sideMenu()
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
                        let color1 = Color(red: 227/255, green: 193/255, blue: 111/255)
                        let color2 = Color(red: 184/255, green: 139/255, blue: 74/255)
                        
                        ChessBoardView(squareSize: squareSize, color1: color1, color2: color2)
                            .frame(width: size, height: size)
                        
                        ChessPiecesView(board: board, squareSize: squareSize, selectedPiece: $selectedPiece, legalMoves: $legalMoves, legalCaptures: $legalCaptures, selectedPosition: $selectedPosition, whiteMove: $whiteMove, isMate: $isMate, selectedMoveIndex: $selectedMoveIndex)
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
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                            .padding(.bottom, 20)
                            .padding(.trailing, 20)
                            .padding(.leading, 20)
                    }
                    .padding(.top, 10)
                }
                if showingPromotionDialog, let details = promotionDetails {
                    PromotionDialogOverlay(details: details, size: size, onSelect: { piece in
                        details.3(piece)
                        showingPromotionDialog = false
                    })
                }
            }
            .background(Color.white)
//            .ignoresSafeArea()
            .onReceive(board.promotionPublisher) { details in
                self.promotionDetails = details
                self.showingPromotionDialog = true
            }
            
        }
        
    }
    
    private func pointDifference() -> Int? {
        let whitePoints = board.capturedPieces.calculateWhitePoints()
        let blackPoints = board.capturedPieces.calculateBlackPoints()
        return whitePoints - blackPoints
    }
    
    private func undoMove() {
        selectedMoveIndex = board.undoMove(selectedMoveIndex: selectedMoveIndex)
        selectedPiece = nil
        legalMoves = []
        legalCaptures = []
        whiteMove = board.getMoveLog().last?.piece.color == "white" ? false : true
        isMate = board.getMoveLog().last?.isCheckmate == true ? true : false
    }
    
    private func redoMove() {
        selectedMoveIndex = board.redoMove(selectedMoveIndex: selectedMoveIndex)
        selectedPiece = nil
        legalMoves = []
        legalCaptures = []
        whiteMove = board.getMoveLog().last?.piece.color == "white" ? false : true
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
    }
}

struct CapturedPiecesView: View {
    var capturedPieces: [String: [GamePiece]]
    var body: some View {
        HStack(spacing: -10) {
            let order = ["queen", "rook", "bishop", "knight", "pawn"]

            ForEach(order, id: \.self) { pieceType in
                if let pieces = capturedPieces[pieceType], !pieces.isEmpty {
                    ForEach(pieces.indices, id: \.self) { index in
                        if let img = pieces[index].img {
                            Image(uiImage: img)
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                    }
                }
            }
        }
    }
}

struct MoveLogView: View {
    @ObservedObject var board: Board
    @Binding var selectedMoveIndex: Int?
    @Binding var whiteMove: Bool
    @Binding var isMate: Bool
    
    var body: some View {
        let moves = board.getMoveLog() + board.undoneMoves.getUndoneMoves()
        ScrollView {
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
                                    .foregroundColor(selectedMoveIndex == moveIndex ? .blue : Color.black.opacity(0.4))  // Apply transparency to the move
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            .onTapGesture {
                                selectedMoveIndex = moveIndex
                                setMove(index: moveIndex)
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
                                .foregroundColor(selectedMoveIndex == moveIndex ? .blue : Color.black.opacity(0.4))  // Apply transparency to the move
                                .fixedSize(horizontal: true, vertical: false)
                            }
                            .onTapGesture {
                                selectedMoveIndex = moveIndex
                                setMove(index: moveIndex)
                            }
                        }
                    }
                    Divider()
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)  // Align to top
            .padding(.horizontal, 10)
        }
    }
    
    private func setMove(index: Int) {
        board.setMove(index: index)
        whiteMove = board.getMoveLog().last?.piece.color == "white" ? false : true
        isMate = board.getMoveLog().last?.isCheckmate == true ? true : false
    }
}

struct ChessBoardView: View {
    var squareSize: CGFloat
    var color1: Color
    var color2: Color
    var columnCoordinates = ["a", "b", "c", "d", "e", "f", "g", "h"]
    var rowCoordinates = ["1", "2", "3", "4", "5", "6", "7", "8"]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { col in
                        ZStack {
                            Rectangle()
                                .fill((row + col) % 2 == 0 ? color1 : color2)
                                .frame(width: squareSize, height: squareSize)
                            GeometryReader { geometry in
                                if (row == 7) {
                                    Text(columnCoordinates[col])
                                        .foregroundColor(Color.black.opacity(0.5))
                                        .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.85)
                                        .font(.system(size: 12))
                                }
                                if (col == 0) {
                                    Text(rowCoordinates[7 - row])
                                        .foregroundColor(Color.black.opacity(0.5))
                                        .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.2)
                                        .font(.system(size: 12))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

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
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    let checkFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        VStack(spacing: 0) {
            if let lastMove = board.getMoveLog().last {
                if lastMove.isCheck == true {
                    ZStack {
                        let (kingRow, kingCol) = self.board.getKingPosition(color: whiteMove ? "white" : "black")
                        RadialGradient(colors: [.red, .clear], center: .center, startRadius: 10, endRadius: 30)
                            .frame(width: squareSize, height: squareSize)
                            .position(x: CGFloat(kingCol) * squareSize + squareSize / 2, y: CGFloat(kingRow) * squareSize + squareSize / 2)
                            .opacity(glowOpacity)
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                    glowOpacity = 1.0
                                }
                            }
                            .onDisappear {
                                glowOpacity = 0.3
                            }
                    }
                }
            }
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { col in
                        ZStack {
                            if let ep = enPassantPosition, ep == (row, col) {
                                RadialGradient(colors: [.red, .clear], center: .center, startRadius: 10, endRadius: 30)
                                    .position(x: CGFloat(squareSize * 0.5), y: CGFloat(squareSize * 0.5))
                                    .opacity(0.8)
                                
                            }
                            if legalMoves.contains(where: { $0 == (row, col)}) {
                                if legalCaptures.contains(where: { $0 == (row, col) }) {
                                    RadialGradient(colors: [.red, .clear], center: .center, startRadius: 10, endRadius: 30)
                                        .position(x: CGFloat(squareSize * 0.5), y: CGFloat(squareSize * 0.5))
                                        .opacity(0.8)
                                        .onTapGesture {
                                            feedbackGenerator.impactOccurred()
                                            movePiece(to: (row, col))
                                        }
                                } else {
                                    Circle()
                                        .fill(Color.blue.opacity(0.25))
                                        .shadow(color: Color.black.opacity(0.6), radius: 4, x: 2, y: 2)
                                        .frame(width: squareSize * 0.5, height: squareSize * 0.5)
                                        .onTapGesture {
                                            feedbackGenerator.impactOccurred()
                                            movePiece(to: (row, col))
                                        }
                                }
                            }
                            if let piece = board.getPiece(row: row, col: col) {
                                Image(uiImage: piece.img!)
                                    .resizable()
                                    .frame(width: squareSize * 0.9, height: squareSize * 0.9)
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

        if let last = board.getMoveLog().last {
            if last.isCheckmate {
                isMate = true
            }
        }
        
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

struct sideMenu: View {
    @State private var showMenu = false
    
    var body: some View {
        VStack {

        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showMenu.toggle()
                }, label: {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(Color.blue)
                })
            }
        }
    }
}

struct PromotionDialogOverlay: View {
    let details: (Int, Int, String, (GamePiece) -> Void)
    let size: CGFloat
    var onSelect: (GamePiece) -> Void

    var body: some View {
        VStack {
            HStack {
                ForEach(["queen", "rook", "bishop", "knight"], id: \.self) { type in
                    Button(action: {
                        let newPiece = createPiece(type: type, color: details.2)
                        onSelect(newPiece)
                    }) {
                        Image(uiImage: UIImage(named: "\(details.2)_\(type)")!)
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(width: size * 0.5, height: size * 0.25)
        .position(x: size / 2, y: size / 2) // Center in the chessboard
    }
    
    private func createPiece(type: String, color: String) -> GamePiece {
        switch type {
        case "queen":
            return Queen(row: 0, col: 0, color: color)
        case "rook":
            return Rook(row: 0, col: 0, color: color, id: "\(color)_rook")
        case "bishop":
            return Bishop(row: 0, col: 0, color: color)
        case "knight":
            return Knight(row: 0, col: 0, color: color)
        default:
            return Queen(row: 0, col: 0, color: color)
        }
    }
}

#Preview {
    ExplorerView()
}
