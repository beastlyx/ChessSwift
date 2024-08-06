import Foundation
import Combine

class Board: ObservableObject {
    @Published var board: [[GamePiece?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
    @Published var moveLog: [MoveLog] = []
//    @Published var undoneMoves = BoardState()
    var capturedPiecesWhite: [String : Int] = [:]
    var capturedPiecesBlack: [String : Int] = [:]
    var blackKingPosition: Position
    var whiteKingPosition: Position
    var halfMove: Int = 0
    var fullMove: Int = 0
    var whiteTurn: Bool = true
    
    var test: Bool
    var promotionPublisher = PassthroughSubject<(Position, String, (GamePiece) -> Void), Never>()
    var cancellables = Set<AnyCancellable>()

    
    init() {
        moveLog = []
        blackKingPosition = Position(x: 0, y: 4)
        whiteKingPosition = Position(x: 7, y: 4)
        test = false
        self.capturedPiecesBlack = [
            "p" : 0,
            "r" : 0,
            "n" : 0,
            "b" : 0,
            "q" : 0
        ]
        self.capturedPiecesWhite = [
            "P" : 0,
            "R" : 0,
            "N" : 0,
            "B" : 0,
            "Q" : 0
        ]
        initializeBoard()
    }
    
    func initializeBoard() {
        let rook_black_1 = Rook(position: Position(x: 0, y: 0), color: "black", id: "1b")
        let rook_white_1 = Rook(position: Position(x: 7, y: 0), color: "white", id: "1w")
        let rook_black_2 = Rook(position: Position(x: 0, y: 7), color: "black", id: "2b")
        let rook_white_2 = Rook(position: Position(x: 7, y: 7), color: "white", id: "2w")

        let bishop_black_1 = Bishop(position: Position(x: 0, y: 2), color: "black")
        let bishop_white_1 = Bishop(position: Position(x: 7, y: 2), color: "white")
        let bishop_black_2 = Bishop(position: Position(x: 0, y: 5), color: "black")
        let bishop_white_2 = Bishop(position: Position(x: 7, y: 5), color: "white")

        let knight_black_1 = Knight(position: Position(x: 0, y: 1), color: "black")
        let knight_white_1 = Knight(position: Position(x: 7, y: 1), color: "white")
        let knight_black_2 = Knight(position: Position(x: 0, y: 6), color: "black")
        let knight_white_2 = Knight(position: Position(x: 7, y: 6), color: "white")

        let queen_black = Queen(position: Position(x: 0, y: 3), color: "black")
        let queen_white = Queen(position: Position(x: 7, y: 3), color: "white")

        let king_black = King(position: Position(x: 0, y: 4), color: "black")
        let king_white = King(position: Position(x: 7, y: 4), color: "white")

        self.board[0][0] = rook_black_1
        self.board[0][1] = knight_black_1
        self.board[0][2] = bishop_black_1
        self.board[0][3] = queen_black
        self.board[0][4] = king_black
        self.board[0][5] = bishop_black_2
        self.board[0][6] = knight_black_2
        self.board[0][7] = rook_black_2

        for i in 0..<8 {
            self.board[1][i] = Pawn(position: Position(x: 1, y: i), color: "black")
            self.board[6][i] = Pawn(position: Position(x: 6, y: i), color: "white")
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
        self.blackKingPosition = Position(x: 0, y: 4)
        self.whiteKingPosition = Position(x: 7, y: 4)
        self.test = false
        self.board = Array(repeating: Array(repeating: nil, count: 8), count: 8)
//        self.undoneMoves.reset()
        self.capturedPiecesBlack = [
            "p" : 0,
            "r" : 0,
            "n" : 0,
            "b" : 0,
            "q" : 0
        ]
        self.capturedPiecesWhite = [
            "P" : 0,
            "R" : 0,
            "N" : 0,
            "B" : 0,
            "Q" : 0
        ]
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
    
    func applyMove(from: Position, to: Position, isPromotion: Bool, pieceType: String) {
        if isPromotion {
            if let originalPawn = getPiece(position: from) {
                let piece = createPiece(type: pieceType, color: originalPawn.color)
                makeMove(piece: piece, capturedPiece: getPiece(position: to), fromPosition: from, newPosition: to, isPromotion: true, isCastle: false, isEnPassant: false, originalPawn: originalPawn)
            }
        } else {
            if let piece = getPiece(position: from) {
                movePiece(piece: piece, newPosition: to)
            }
        }
    }
    
    private func createPiece(type: String, color: String) -> GamePiece {
        switch type {
        case "queen":
            return Queen(position: Position(x: 0, y: 0), color: color)
        case "rook":
            return Rook(position: Position(x: 0, y: 0), color: color, id: "\(color)-rook")
        case "bishop":
            return Bishop(position: Position(x: 0, y: 0), color: color)
        case "knight":
            return Knight(position: Position(x: 0, y: 0), color: color)
        default:
            return Pawn(position: Position(x: 0, y: 0), color: color)
        }
    }

    func setMove(index: Int) {
        guard index >= 0 || index < self.getMoveLog().count else { return }
        
        let fen = self.getMoveLog()[index].FEN
        
        let fenSplit = fen.split(separator: " ")
        let rows = String(fenSplit[0]).split(separator: "/")
        let turn = String(fenSplit[1])
        let castleRights = String(fenSplit[2])
        let enPassant = String(fenSplit[3])
        let halfMove = String(fenSplit[4])
        let fullMove = String(fenSplit[5])
        
        var newBoard: [[GamePiece?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        
        for (rowIndex, row) in rows.enumerated() {
            var empty = 0
            for col in row {
                if let type = col.wholeNumberValue {
                    empty += type
                } else {
                    newBoard[rowIndex][empty] = generatePiece(type: String(col), position: Position(x: rowIndex, y: empty))
                    empty += 1
                }
            }
        }
        
        self.board = newBoard
        self.updateCapturedPieces()
        self.whiteTurn = turn == "b" ? true : false
        
        if castleRights != "-" {
            if let whiteKing = self.getPiece(position: self.getKingPosition(color: "white")) as? King, 
                let blackKing = self.getPiece(position: self.getKingPosition(color: "black")) as? King {
                
                whiteKing.canCastleKingSide = false
                whiteKing.canCastleQueenSide = false
                
                blackKing.canCastleKingSide = false
                blackKing.canCastleQueenSide = false
                
                for char in castleRights {
                    switch char {
                    case "q":
                        blackKing.canCastleQueenSide = true
                    case "Q":
                        whiteKing.canCastleQueenSide = true
                    case "k":
                        blackKing.canCastleKingSide = true
                    case "K":
                        blackKing.canCastleQueenSide = true
                    default:
                        continue
                    }
                }
            }
        }
        
        if enPassant != "-" {
            let first = Array(enPassant)[0]
            let second = Array(enPassant)[1]
            if second == "3" {
                // white piece enpassant
                if let ascii = first.asciiValue {
                    let col = Int(ascii) - Int(Character("a").asciiValue!)
                    if let piece = self.getPiece(position: Position(x: 3, y: col)) as? Pawn {
                        piece.isEnPassant = true
                    }
                }
            } else {
                // black piece enpassant
                if let ascii = first.asciiValue {
                    let col = Int(ascii) - Int(Character("a").asciiValue!)
                    if let piece = self.getPiece(position: Position(x: 6, y: col)) as? Pawn {
                        piece.isEnPassant = true
                    }
                }
            }
        }
        
        self.halfMove = Int(halfMove) ?? 0
        self.fullMove = Int(fullMove) ?? 0
    }
    
    private func generatePiece(type: String, position: Position) -> GamePiece? {
        switch type {
        case "q":
            return Queen(position: position, color: "black")
        case "Q":
            return Queen(position: position, color: "white")
        case "r":
            return Rook(position: position, color: "black", id: "black-rook")
        case "R":
            return Rook(position: position, color: "white", id: "white-rook")
        case "b":
            return Bishop(position: position, color: "black")
        case "B":
            return Bishop(position: position, color: "white")
        case "n":
            return Knight(position: position, color: "black")
        case "N":
            return Knight(position: position, color: "white")
        case "k":
            return King(position: position, color: "black")
        case "K":
            return King(position: position, color: "white")
        case "p":
            return Pawn(position: position, color: "black")
        case "P":
            return Pawn(position: position, color: "white")
        default:
            return nil
        }
    }
    
    func calculateWhitePoints() -> Int {
        var whitePoints = 0
        for (key, value) in self.capturedPiecesWhite {
            switch key {
            case "Q":
                whitePoints += value > 0 ? (9 * value) : 0
            case "R":
                whitePoints += value > 0 ? (5 * value) : 0
            case "B":
                whitePoints += value > 0 ? (3 * value) : 0
            case "N":
                whitePoints += value > 0 ? (3 * value) : 0
            case "P":
                whitePoints += value > 0 ? (1 * value) : 0
            default:
                break
            }
        }
        return whitePoints
    }

    func calculateBlackPoints() -> Int {
        var blackPoints = 0
        for (key, value) in self.capturedPiecesBlack {
            switch key {
            case "q":
                blackPoints += value > 0 ? (9 * value) : 0
            case "r":
                blackPoints += value > 0 ? (5 * value) : 0
            case "b":
                blackPoints += value > 0 ? (3 * value) : 0
            case "n":
                blackPoints += value > 0 ? (3 * value) : 0
            case "p":
                blackPoints += value > 0 ? (1 * value) : 0
            default:
                break
            }
        }
        return blackPoints
    }

    private func updateCapturedPieces() {
        self.capturedPiecesBlack = [
            "p" : 8,
            "r" : 2,
            "n" : 2,
            "b" : 2,
            "q" : 1
        ]
        self.capturedPiecesWhite = [
            "P" : 8,
            "R" : 2,
            "N" : 2,
            "B" : 2,
            "Q" : 1
        ]
        
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = self.getPiece(position: Position(x: row, y: col)), piece.pieceType != "king" {
                    if piece.color == "black" {
                        self.capturedPiecesBlack[piece.pieceCoordinates]! -= 1
                    } else {
                        self.capturedPiecesWhite[piece.pieceCoordinates]! -= 1
                    }
                }
            }
        }
    }
    
    func makeMove(piece: GamePiece?, capturedPiece: GamePiece? = nil, fromPosition: Position, newPosition: Position, isPromotion: Bool, isCastle: Bool, isEnPassant: Bool, originalPawn: GamePiece?) {
        guard let piece = piece else { return }
        var capturedPiece = capturedPiece
        let (newRow, newCol) = newPosition.destructure()
        let (currRow, currCol) = fromPosition.destructure()
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
        piece.position = Position(x: newRow, y: newCol)
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
            if let _ = capturedPiece, isPromotion == true {
                self.halfMove = 0
            } else {
                self.halfMove += 1
            }
            
            if piece.color == "black" {
                self.fullMove += 1
            }
            
            let move = MoveLog(board: self, piece: piece, capturedPiece: capturedPiece, oldPosition: fromPosition, newPosition: newPosition, isPromotion: isPromotion, isCastle: isCastle, isEnPassant: isEnPassant, originalPawn: originalPawn)
            move.addMove()
            self.moveLog.append(move.getMove())
            
            self.updateCapturedPieces()
            self.whiteTurn.toggle()
        }
    }

    
    func movePiece(piece: GamePiece?, newPosition: Position, test: Bool = false) {//, legal_captures, test=False):
        self.test = test
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
    
    func movePawn(piece: GamePiece, newPosition: Position) {
        let (row, col) = piece.position.destructure()
        // Pawn promotion to queen
        if piece.color == "white" && newPosition.x == 0 || piece.color == "black" && newPosition.x == 7 && !self.test {
            let capturedPiece = self.board[newPosition.x][newPosition.y]
            let originalPawn = self.board[row][col]
            self.board[row][col] = nil
                    
            handlePawnPromotion(newPosition: newPosition, color: piece.color)
            .sink { [weak self] newPiece in
                guard let self = self else { return }
                self.makeMove(piece: newPiece, capturedPiece: capturedPiece, fromPosition: Position(x: row, y: col), newPosition: newPosition, isPromotion: true, isCastle: false, isEnPassant: false, originalPawn: originalPawn)
            }
            .store(in: &cancellables)
//            self.handlePawnPromotion(newPosition: newPosition, color: piece.color) { newPiece in
//                self.makeMove(piece: newPiece, capturedPiece: capturedPiece, fromPosition: (row, col), newPosition: newPosition, isPromotion: true, isCastle: false, isEnPassant: false, originalPawn: originalPawn)
//            }
        }
        // white en passant capture
        else if piece.color == "white" && row == 3 && self.board[newPosition.x][newPosition.y] == nil {
            if newPosition == Position(x: row - 1, y: col - 1) || newPosition == Position(x: row - 1, y: col + 1) {
                let pawn = self.getPiece(position: Position(x: newPosition.x + 1, y: newPosition.y))
                self.makeMove(piece: piece, fromPosition: Position(x: row, y: col), newPosition: newPosition, isPromotion: false, isCastle: false, isEnPassant: true, originalPawn: pawn)
            }
            else {
                self.makeMove(piece: piece, fromPosition: Position(x: row, y: col), newPosition: newPosition, isPromotion: false, isCastle: false, isEnPassant: false, originalPawn: nil)
            }
        }
        // black en passant capture
        else if piece.color == "black" && row == 4 && self.board[newPosition.x][newPosition.y] == nil {
            if newPosition == Position(x: row + 1, y: col - 1) || newPosition == Position(x: row + 1, y: col + 1) {
                let pawn = self.getPiece(position: Position(x: newPosition.x - 1, y: newPosition.y))
                self.makeMove(piece: piece, fromPosition: Position(x: row, y: col), newPosition: newPosition, isPromotion: false, isCastle: false, isEnPassant: true, originalPawn: pawn)
            }
            else {
                self.makeMove(piece: piece, fromPosition: Position(x: row, y: col), newPosition: newPosition, isPromotion: false, isCastle: false, isEnPassant: false, originalPawn: nil)
            }
        }
        else {
            self.makeMove(piece: piece, fromPosition: Position(x: row, y: col), newPosition: newPosition, isPromotion: false, isCastle: false, isEnPassant: false, originalPawn: nil)
        }
    }

    func moveKing(piece: GamePiece, newPosition: Position) {
        let (currRow, currCol) = piece.position.destructure()
        let isCastling = abs(currCol - newPosition.y) == 2
        if isCastling {
            var rookInitialPosition: Position
            var rookFinalPosition: Position
            // Kingside castling
            if newPosition.y > currCol {
                rookInitialPosition = Position(x: currRow, y: 7)
                rookFinalPosition = Position(x: newPosition.x, y: newPosition.y - 1)
            }
            // Queenside castling
            else {
                rookInitialPosition = Position(x: currRow, y: 0)
                rookFinalPosition = Position(x: newPosition.x, y: newPosition.y + 1)
            }
            let rook = self.board[rookInitialPosition.x][rookInitialPosition.y]
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
    
//    func handlePawnPromotion(newPosition: (Int, Int), color: String, completion: @escaping (GamePiece) -> Void) {
//        DispatchQueue.main.async {
//            self.promotionPublisher.send((newPosition.0, newPosition.1, color, { piece in
//                completion(piece)
//            }))
//        }
//    }
    func handlePawnPromotion(newPosition: Position, color: String) -> Future<GamePiece, Never> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.promotionPublisher.send((newPosition, color, { piece in
                    promise(.success(piece))
                }))
            }
        }
    }
    func getPiece(position: Position) -> GamePiece? {
        let (row, col) = position.destructure()
        if row < 0 || row > 7 || col < 0 || col > 7 {
            return nil
        }
        guard let piece = self.board[row][col] else { return nil }
        return piece
    }
    
    func getKingPosition(color: String) -> Position {
        return color == "white" ? self.whiteKingPosition : self.blackKingPosition
    }
    
    func getMoveLog() -> [MoveLog] {
        return self.moveLog
    }
}
