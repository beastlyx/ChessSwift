import Foundation
import Combine

class Board: ObservableObject {
    @Published var board: [[GamePiece?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
    @Published var moveLog: [MoveLog] = []
    @Published var undoneMoves = BoardState()
    var capturedPieces: CapturedPieces
    var blackKingPosition: (Int, Int)
    var whiteKingPosition: (Int, Int)
    var test: Bool
    var promotionPublisher = PassthroughSubject<(Int, Int, String, (GamePiece) -> Void), Never>()
    
    private var snapshots: [Int: Board] = [:]
    
    init() {
        moveLog = []
        blackKingPosition = (0, 4)
        whiteKingPosition = (7, 4)
        test = false
        capturedPieces = CapturedPieces()
        
        initializeBoard()
    }
    
    func initializeBoard() {
        let rook_black_1 = Rook(row: 0, col: 0, color: "black", id: "1b")
        let rook_white_1 = Rook(row: 7, col: 0, color: "white", id: "1w")
        let rook_black_2 = Rook(row: 0, col: 7, color: "black", id: "2b")
        let rook_white_2 = Rook(row: 7, col: 7, color: "white", id: "2w")

        let bishop_black_1 = Bishop(row: 0, col: 2, color: "black")
        let bishop_white_1 = Bishop(row: 7, col: 2, color: "white")
        let bishop_black_2 = Bishop(row: 0, col: 5, color: "black")
        let bishop_white_2 = Bishop(row: 7, col: 5, color: "white")

        let knight_black_1 = Knight(row: 0, col: 1, color: "black")
        let knight_white_1 = Knight(row: 7, col: 1, color: "white")
        let knight_black_2 = Knight(row: 0, col: 6, color: "black")
        let knight_white_2 = Knight(row: 7, col: 6, color: "white")

        let queen_black = Queen(row: 0, col: 3, color: "black")
        let queen_white = Queen(row: 7, col: 3, color: "white")

        let king_black = King(row: 0, col: 4, color: "black")
        let king_white = King(row: 7, col: 4, color: "white")

        self.board[0][0] = rook_black_1
        self.board[0][1] = knight_black_1
        self.board[0][2] = bishop_black_1
        self.board[0][3] = queen_black
        self.board[0][4] = king_black
        self.board[0][5] = bishop_black_2
        self.board[0][6] = knight_black_2
        self.board[0][7] = rook_black_2

        for i in 0..<8 {
            self.board[1][i] = Pawn(row: 1, col: i, color: "black")
            self.board[6][i] = Pawn(row: 6, col: i, color: "white")
        }
        
        self.board[7][0] = rook_white_1
        self.board[7][1] = knight_white_1
        self.board[7][2] = bishop_white_1
        self.board[7][3] = queen_white
        self.board[7][4] = king_white
        self.board[7][5] = bishop_white_2
        self.board[7][6] = knight_white_2
        self.board[7][7] = rook_white_2
    }
    
    func reset() {
        self.moveLog = []
        self.blackKingPosition = (0, 4)
        self.whiteKingPosition = (7, 4)
        self.test = false
        self.board = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        self.undoneMoves.reset()
        self.capturedPieces.reset()
        
        initializeBoard()
    }
    
    func deepCopy() -> Board {
        let newBoard = Board()
        newBoard.blackKingPosition = self.blackKingPosition
        newBoard.whiteKingPosition = self.whiteKingPosition
        newBoard.test = self.test
        newBoard.moveLog = self.moveLog.map { move in
            move.copy()
        }
        newBoard.board = self.board.map { row in
            row.map { piece in
                piece?.copy()
            }
        }
        newBoard.capturedPieces = self.capturedPieces.deepCopy()
        return newBoard
    }
    
    subscript(row: Int, col: Int) -> GamePiece? {
        get {
            return self.board[row][col]
        }
        set {
            self.board[row][col] = newValue
        }
    }
    
//    private func printSnapshot() {
//        let keys = self.snapshots.keys.sorted()
//        for key in keys {
//            if let value = self.snapshots[key] {
//                print("index: \(key)")
//                print("board:")
//                printBoard(board: value)
//                print()
//                print("MoveLog: \(value.moveLog.map {$0.move})")
//                printCapturedPieces(cp: value.capturedPieces)
//                print()
//            } else {
//                print("index: \(key)")
//                print("value: nil")
//                print()
//            }
//        }
//    }
//    private func printCapturedPieces(cp: CapturedPieces) {
//        print("Captured White Pieces:")
//        for (type, pieces) in cp.getWhiteCapturedPieces() {
//            let piecesString = pieces.map { $0.pieceType }.joined(separator: ", ")
//            print("\(type.capitalized): \(piecesString)")
//        }
//        
//        print("\nCaptured Black Pieces:")
//        for (type, pieces) in cp.getBlackCapturedPieces() {
//            let piecesString = pieces.map { $0.pieceType }.joined(separator: ", ")
//            print("\(type.capitalized): \(piecesString)")
//        }
//    }
//    private func printBoard(board: Board) {
//        for row in board.board {
//            let rowString = row.map { piece -> String in
//                if let piece = piece {
//                    return piece.pieceType.padding(toLength: 10, withPad: " ", startingAt: 0)
//                } else {
//                    return "nil".padding(toLength: 10, withPad: " ", startingAt: 0)
//                }
//            }.joined(separator: " ")
//            print(rowString)
//        }
//    }
    func setMove(index: Int) {
//        printSnapshot()
        let moves = self.getMoveLog() + self.undoneMoves.getUndoneMoves()
        let length = moves.count
        
        let logCount = self.getMoveLog().count
        if index < logCount {
            var movesToUndo = logCount - 1 - index
            while !self.getMoveLog().isEmpty && movesToUndo > 0 {
//                let move = self.getMoveLog().last
//                if let capturedPiece = move?.capturedPiece {
//                    self.capturedPieces.undoCapturedPiece(capturedPiece: capturedPiece)
//                }
                UndoMove(board: self).undo()
                movesToUndo -= 1
            }
        } else if index < length {
            var movesToRedo = index - logCount + 1
            while !self.undoneMoves.getUndoneMoves().isEmpty && movesToRedo > 0 {
                self.undoneMoves.redo()
                movesToRedo -= 1
            }
        }
    }
    
    func redoMove(selectedMoveIndex: Int?) -> Int? {
        if !self.undoneMoves.getUndoneMoves().isEmpty {
            self.undoneMoves.redo()
            
            let length = self.getMoveLog().count + self.undoneMoves.getUndoneMoves().count - 1
            var index = selectedMoveIndex
            if let moveIndex = selectedMoveIndex {
                index = min(moveIndex + 1, length)
            } else {
                index = 0
            }
            return index
        }
        return selectedMoveIndex
    }
    
    func undoMove(selectedMoveIndex: Int?) -> Int? {
        if !self.getMoveLog().isEmpty {
//            let move = self.getMoveLog().last
//            if let capturedPiece = move?.capturedPiece {
//                self.capturedPieces.undoCapturedPiece(capturedPiece: capturedPiece)
//            }
            UndoMove(board: self).undo()
            
            var index = self.getMoveLog().count - 1
            if let moveIndex = selectedMoveIndex {
                index = moveIndex - 1
            }
            return index < 0 ? nil : index
        }
        return selectedMoveIndex
    }
    
//    func createSnapshot(at index: Int) {
//        self.snapshots[index] = self.deepCopy()
//    }
//    
//    func getSnapshot(at index: Int) -> Board? {
//        return self.snapshots[index]
//    }
//    
//    func findSnapshot(at index: Int) -> (index: Int, snapshot: Board) {
//        let keys = self.snapshots.keys.sorted()
//        if let closest = keys.last(where: { $0 <= index }) {
//            if let snapshot = snapshots[closest] {
//                return (closest, snapshot)
//            }
//        }
//        return (index, self)
//    }
    
    func makeMove(piece: GamePiece?, capturedPiece: GamePiece? = nil, fromPosition: (Int, Int), newPosition: (Int, Int), isPromotion: Bool, isCastle: Bool, isEnPassant: Bool, originalPawn: GamePiece?) {
        guard let piece = piece else { return }
        var capturedPiece = capturedPiece
        let (newRow, newCol) = newPosition
        let (currRow, currCol) = fromPosition
        if capturedPiece == nil {
            capturedPiece = board[newRow][newCol]
        }
        if isEnPassant {
            if piece.color == "white" {
                capturedPiece = self.board[newRow + 1][newCol]
                self.board[newRow + 1][newCol] = nil
            } else {
                capturedPiece = self.board[newRow - 1][newCol]
                self.board[newRow - 1][newCol] = nil
            }
        }
        
        self.board[currRow][currCol] = nil
        self.board[newRow][newCol] = nil
        self.board[newRow][newCol] = piece
        piece.position = (newRow, newCol)
        if piece.pieceType == "king" {
            if piece.color == "white" {
                self.whiteKingPosition = newPosition
            }
            else {
                self.blackKingPosition = newPosition
            }
        }
            
        if isCastle && piece.pieceType == "rook" {
            return
        }
        
        if (!self.test) {
            if let capturedPiece = capturedPiece {
                capturedPieces.capturePiece(capturedPiece: capturedPiece)
            }
            let move = MoveLog(board: self, piece: piece, capturedPiece: capturedPiece, oldPosition: fromPosition, newPosition: newPosition, isPromotion: isPromotion, isCastle: isCastle, isEnPassant: isEnPassant, originalPawn: originalPawn)
            move.addMove()
            self.moveLog.append(move.getMove())
            
//            if moveLog.count % 5 == 0 {
//                if snapshots[moveLog.count] == nil {
//                    createSnapshot(at: moveLog.count)
//                }
//            }
        }
    }

    
    func movePiece(piece: GamePiece?, newPosition: (Int, Int), test: Bool = false) {//, legal_captures, test=False):
        self.test = test
        // if self.board[new_pos[0]][new_pos[1]] is None or (self.board[new_pos[0]][new_pos[1]] is not None and (new_pos[0], new_pos[1]) in legal_captures):
        guard let piece = piece else { return }
        if piece.pieceType == "pawn" {
            self.movePawn(piece: piece, newPosition: newPosition)
        }
        else if piece.pieceType == "king" && !piece.pieceMoved {
            self.moveKing(piece: piece, newPosition: newPosition)
        }
        else {
            self.makeMove(piece: piece, fromPosition: piece.position, newPosition: newPosition, isPromotion: false, isCastle: false, isEnPassant: false, originalPawn: nil)
        }
    }
        
    func movePawn(piece: GamePiece, newPosition: (Int, Int)) {
        let (row, col) = piece.position
        // Pawn promotion to queen
        if piece.color == "white" && newPosition.0 == 0 || piece.color == "black" && newPosition.0 == 7 {
            let capturedPiece = self.board[newPosition.0][newPosition.1]
            let originalPawn = self.board[row][col]
            self.board[row][col] = nil
            self.handlePawnPromotion(newPosition: newPosition, color: piece.color) { newPiece in
                DispatchQueue.main.async {
                    self.makeMove(piece: newPiece, capturedPiece: capturedPiece, fromPosition: (row, col), newPosition: newPosition, isPromotion: true, isCastle: false, isEnPassant: false, originalPawn: originalPawn)
                }
            }
        }
        // white en passant capture
        else if piece.color == "white" && row == 3 && self.board[newPosition.0][newPosition.1] == nil {
            if newPosition == (row - 1, col - 1) || newPosition == (row - 1, col + 1) {
                let pawn = self.getPiece(row: newPosition.0 + 1, col: newPosition.1)
                self.makeMove(piece: piece, fromPosition: (row, col), newPosition: newPosition, isPromotion: false, isCastle: false, isEnPassant: true, originalPawn: pawn)
            }
            else {
                self.makeMove(piece: piece, fromPosition: (row, col), newPosition: newPosition, isPromotion: false, isCastle: false, isEnPassant: false, originalPawn: nil)
            }
        }
        // black en passant capture
        else if piece.color == "black" && row == 4 && self.board[newPosition.0][newPosition.1] == nil {
            if newPosition == (row + 1, col - 1) || newPosition == (row + 1, col + 1) {
                let pawn = self.getPiece(row: newPosition.0 - 1, col: newPosition.1)
                self.makeMove(piece: piece, fromPosition: (row, col), newPosition: newPosition, isPromotion: false, isCastle: false, isEnPassant: true, originalPawn: pawn)
            }
            else {
                self.makeMove(piece: piece, fromPosition: (row, col), newPosition: newPosition, isPromotion: false, isCastle: false, isEnPassant: false, originalPawn: nil)
            }
        }
        else {
            self.makeMove(piece: piece, fromPosition: (row, col), newPosition: newPosition, isPromotion: false, isCastle: false, isEnPassant: false, originalPawn: nil)
        }
    }

    func moveKing(piece: GamePiece, newPosition: (Int, Int)) {
        let (currRow, currCol) = piece.position
        let isCastling = abs(currCol - newPosition.1) == 2
        if isCastling {
            var rookInitialPosition: (Int, Int)
            var rookFinalPosition: (Int, Int)
            // Kingside castling
            if newPosition.1 > currCol {
                rookInitialPosition = (currRow, 7)
                rookFinalPosition = (newPosition.0, newPosition.1 - 1)
            }
            // Queenside castling
            else {
                rookInitialPosition = (currRow, 0)
                rookFinalPosition = (newPosition.0, newPosition.1 + 1)
            }
            let rook = self.board[rookInitialPosition.0][rookInitialPosition.1]
            // king's move
            self.makeMove(piece: piece, fromPosition: piece.position, newPosition: newPosition, isPromotion: false, isCastle: true, isEnPassant: false, originalPawn: nil)
            // rook's move
            self.makeMove(piece: rook, fromPosition: rookInitialPosition, newPosition: rookFinalPosition, isPromotion: false, isCastle: true, isEnPassant: false, originalPawn: nil)
        }
        else {
            // Regular king move
            self.makeMove(piece: piece, fromPosition: piece.position, newPosition: newPosition, isPromotion: false, isCastle: false, isEnPassant: false, originalPawn: nil)
        }
    }
    
    func handlePawnPromotion(newPosition: (Int, Int), color: String, completion: @escaping (GamePiece) -> Void) {
        // Trigger the UI to show the promotion dialog
        DispatchQueue.main.async {
            self.promotionPublisher.send((newPosition.0, newPosition.1, color, { piece in
                completion(piece)
            }))
        }
    }
    
    func getPiece(row: Int, col: Int) -> GamePiece? {
        return self.board[row][col]
    }
    
    func getKingPosition(color: String) -> (Int, Int) {
        return color == "white" ? self.whiteKingPosition : self.blackKingPosition
    }
    
    func getMoveLog() -> [MoveLog] {
        return self.moveLog
    }
}
