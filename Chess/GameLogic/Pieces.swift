import UIKit

class GamePiece: Hashable {
    var legalMoves: [(Int, Int)] = []
    var legalCaptures: [(Int, Int)] = []
    var img: UIImage?
    let originalPosition: (Int, Int)
    var position: (Int, Int)
    let color: String
    var pieceType: String
    var pieceMoved = false
    var pieceCoordinates: String
    var id: String?
    var points = 0
    
    init(row: Int, col: Int, color: String, pieceCoordinates: String, pieceType: String) {
        self.originalPosition = (row, col)
        self.position = (row, col)
        self.color = color
        self.pieceCoordinates = pieceCoordinates
        self.pieceType = pieceType
    }
    
    required init(copying piece: GamePiece) {
        self.legalMoves = piece.legalMoves
        self.legalCaptures = piece.legalCaptures
        self.img = piece.img
        self.originalPosition = piece.originalPosition
        self.position = piece.position
        self.color = piece.color
        self.pieceType = piece.pieceType
        self.pieceMoved = piece.pieceMoved
        self.pieceCoordinates = piece.pieceCoordinates
        self.id = piece.id
        self.points = piece.points
    }
    
    func copy() -> GamePiece {
        return GamePiece(copying: self)
    }
    
    func getImagePath() -> String {
        return "\(color)-\(pieceType).png"
    }
    
    func setLegalMoves(board: Board) -> [(Int, Int)] {
        calculateMoves(board: board)
        return legalMoves
    }
    
    @discardableResult
    func getLegalMoves(board: Board) -> [(Int, Int)] {
        calculateMoves(board: board)
        return legalMoves
    }
    
    func getLegalCaptures(board: Board) -> [(Int, Int)] {
        calculateCaptures(board: board)
        return legalCaptures
    }
    
    func validateLegalMoves(board: Board) -> [(Int, Int)] {
        validateMoves(board: board)
        return legalMoves
    }
    
    func calculateMoves(board: Board) {
        // Override in subclasses
    }
    
    func calculateCaptures(board: Board) {
        // Override in subclasses
    }
    
    func validateMoves(board: Board) {
        // Override in subclasses
    }
    static func == (lhs: GamePiece, rhs: GamePiece) -> Bool {
        return lhs.color == rhs.color && lhs.img == rhs.img && lhs.position == rhs.position
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class Rook: GamePiece {
    init(row: Int, col: Int, color: String, id: String) {
        super.init(row: row, col: col, color: color, pieceCoordinates: "R", pieceType: "rook")
        self.id = id
        self.img = UIImage(named: getImagePath())
        self.points = 5
    }
    
    required init(copying piece: GamePiece) {
        let rook = piece as! Rook
        super.init(copying: rook)
        self.id = rook.id
        self.img = rook.img
        self.points = rook.points
    }

    override func copy() -> Rook {
        return Rook(copying: self)
    }
    
    override func calculateMoves(board: Board) {
        let (row, col) = self.position
        if !self.pieceMoved && self.position != self.originalPosition {
            self.pieceMoved = true
        }
        
        var leftHorizontal: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= col - i && col - i < 8 {
                if board.getPiece(row: row, col: col - i) == nil {
                    leftHorizontal.append((row, col - i))
                } else if board.getPiece(row: row, col: col - i)?.color != self.color {
                    leftHorizontal.append((row, col - i))
                    break
                } else {
                    break
                }
            }
        }
        
        var rightHorizontal: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= col + i && col + i < 8 {
                if board.getPiece(row: row, col: col + i) == nil {
                    rightHorizontal.append((row, col + i))
                } else if board.getPiece(row: row, col: col + i)?.color != self.color {
                    rightHorizontal.append((row, col + i))
                    break
                } else {
                    break
                }
            }
        }
        
        var verticalTop: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= row - i && row - i < 8 {
                if board.getPiece(row: row - i, col: col) == nil {
                    verticalTop.append((row - i, col))
                } else if board.getPiece(row: row - i, col: col)?.color != self.color {
                    verticalTop.append((row - i, col))
                    break
                } else {
                    break
                }
            }
        }
        
        var verticalDown: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= row + i && row + i < 8 {
                if board.getPiece(row: row + i, col: col) == nil {
                    verticalDown.append((row + i, col))
                } else if board.getPiece(row: row + i, col: col)?.color != self.color {
                    verticalDown.append((row + i, col))
                    break
                } else {
                    break
                }
            }
        }
        
        self.legalMoves = leftHorizontal + rightHorizontal + verticalTop + verticalDown
    }
    
    override func calculateCaptures(board: Board) {
        var captures: [(Int, Int)] = []
        for move in self.legalMoves {
            if let piece = board.getPiece(row: move.0, col: move.1), piece.color != self.color {
                captures.append((move.0, move.1))
            }
        }
        self.legalCaptures = captures
    }
    
    override func validateMoves(board: Board) {
        var moves: [(Int, Int)] = []
        for move in self.legalMoves {
            let tempBoard = board.deepCopy()
            let tempPiece = self.copy()
            if !CheckConditions(board: tempBoard, piece: tempPiece, move: move).validateMove() {
                moves.append(move)
            }
        }
        self.legalMoves = moves
    }
}

class Knight: GamePiece {
    init(row: Int, col: Int, color: String) {
        super.init(row: row, col: col, color: color, pieceCoordinates: "N", pieceType: "knight")
        self.img = UIImage(named: getImagePath())
        self.points = 3
    }

    required init(copying piece: GamePiece) {
        let knight = piece as! Knight
        super.init(copying: knight)
    }
    
    override func copy() -> Knight {
        return Knight(copying: self)
    }
    override func calculateMoves(board: Board) {
        let (row, col) = self.position
        let moves = [
            (row - 2, col - 1), (row - 1, col - 2), (row + 1, col - 2), (row + 2, col - 1),
            (row + 2, col + 1), (row + 1, col + 2), (row - 1, col + 2), (row - 2, col + 1)
        ]
        var knightMoves: [(Int, Int)] = []
        for move in moves {
            if move.0 >= 0 && move.0 < 8 && move.1 >= 0 && move.1 < 8 {
                if board.getPiece(row: move.0, col: move.1) == nil {
                    knightMoves.append(move)
                } else if let piece = board.getPiece(row: move.0, col: move.1), piece.color != self.color {
                    knightMoves.append(move)
                }
            }
        }
        self.legalMoves = knightMoves
    }
    
    override func calculateCaptures(board: Board) {
        var captures: [(Int, Int)] = []
        for move in self.legalMoves {
            if let piece = board.getPiece(row: move.0, col: move.1), piece.color != self.color {
                captures.append(move)
            }
        }
        self.legalCaptures = captures
    }
    
    override func validateMoves(board: Board) {
        var moves: [(Int, Int)] = []
        for move in self.legalMoves {
            let tempBoard = board.deepCopy()
            let tempPiece = self.copy()
            if !CheckConditions(board: tempBoard, piece: tempPiece, move: move).validateMove() {
                moves.append(move)
            }
        }
        self.legalMoves = moves
    }
}

class Bishop: GamePiece {
    init(row: Int, col: Int, color: String) {
        super.init(row: row, col: col, color: color, pieceCoordinates: "B", pieceType: "bishop")
        self.img = UIImage(named: getImagePath())
        self.points = 3
    }

    required init(copying piece: GamePiece) {
        let bishop = piece as! Bishop
        super.init(copying: bishop)
    }
    
    override func copy() -> Bishop {
        return Bishop(copying: self)
    }
    override func calculateMoves(board: Board) {
        let (row, col) = self.position
        var topLeftDiagonal: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= col - i && col - i < 8 && 0 <= row - i && row - i < 8 {
                if board.getPiece(row: row - i, col: col - i) == nil {
                    topLeftDiagonal.append((row - i, col - i))
                } else if let piece = board.getPiece(row: row - i, col: col - i), piece.color != self.color {
                    topLeftDiagonal.append((row - i, col - i))
                    break
                } else {
                    break
                }
            }
        }

        var bottomLeftDiagonal: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= col - i && col - i < 8 && 0 <= row + i && row + i < 8 {
                if board.getPiece(row: row + i, col: col - i) == nil {
                    bottomLeftDiagonal.append((row + i, col - i))
                } else if let piece = board.getPiece(row: row + i, col: col - i), piece.color != self.color {
                    bottomLeftDiagonal.append((row + i, col - i))
                    break
                } else {
                    break
                }
            }
        }

        var topRightDiagonal: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= col + i && col + i < 8 && 0 <= row - i && row - i < 8 {
                if board.getPiece(row: row - i, col: col + i) == nil {
                    topRightDiagonal.append((row - i, col + i))
                } else if let piece = board.getPiece(row: row - i, col: col + i), piece.color != self.color {
                    topRightDiagonal.append((row - i, col + i))
                    break
                } else {
                    break
                }
            }
        }

        var bottomRightDiagonal: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= col + i && col + i < 8 && 0 <= row + i && row + i < 8 {
                if board.getPiece(row: row + i, col: col + i) == nil {
                    bottomRightDiagonal.append((row + i, col + i))
                } else if let piece = board.getPiece(row: row + i, col: col + i), piece.color != self.color {
                    bottomRightDiagonal.append((row + i, col + i))
                    break
                } else {
                    break
                }
            }
        }

        self.legalMoves = topLeftDiagonal + topRightDiagonal + bottomLeftDiagonal + bottomRightDiagonal
    }
    
    override func calculateCaptures(board: Board) {
        var captures: [(Int, Int)] = []
        for move in self.legalMoves {
            if let piece = board.getPiece(row: move.0, col: move.1), piece.color != self.color {
                captures.append(move)
            }
        }
        self.legalCaptures = captures
    }
    
    override func validateMoves(board: Board) {
        var moves: [(Int, Int)] = []
        for move in self.legalMoves {
            let tempBoard = board.deepCopy()
            let tempPiece = self.copy()
            if !CheckConditions(board: tempBoard, piece: tempPiece, move: move).validateMove() {
                moves.append(move)
            }
        }
        self.legalMoves = moves
    }
}

class Queen: GamePiece {
    init(row: Int, col: Int, color: String) {
        super.init(row: row, col: col, color: color, pieceCoordinates: "Q", pieceType: "queen")
        self.img = UIImage(named: getImagePath())
        self.points = 9
    }

    required init(copying piece: GamePiece) {
        let queen = piece as! Queen
        super.init(copying: queen)
    }
    
    override func copy() -> Queen {
        return Queen(copying: self)
    }
    override func calculateMoves(board: Board) {
        let (row, col) = self.position
        var topLeftDiagonal: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= col - i && col - i < 8 && 0 <= row - i && row - i < 8 {
                if board.getPiece(row: row - i, col: col - i) == nil {
                    topLeftDiagonal.append((row - i, col - i))
                } else if let piece = board.getPiece(row: row - i, col: col - i), piece.color != self.color {
                    topLeftDiagonal.append((row - i, col - i))
                    break
                } else {
                    break
                }
            }
        }

        var bottomLeftDiagonal: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= col - i && col - i < 8 && 0 <= row + i && row + i < 8 {
                if board.getPiece(row: row + i, col: col - i) == nil {
                    bottomLeftDiagonal.append((row + i, col - i))
                } else if let piece = board.getPiece(row: row + i, col: col - i), piece.color != self.color {
                    bottomLeftDiagonal.append((row + i, col - i))
                    break
                } else {
                    break
                }
            }
        }

        var topRightDiagonal: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= col + i && col + i < 8 && 0 <= row - i && row - i < 8 {
                if board.getPiece(row: row - i, col: col + i) == nil {
                    topRightDiagonal.append((row - i, col + i))
                } else if let piece = board.getPiece(row: row - i, col: col + i), piece.color != self.color {
                    topRightDiagonal.append((row - i, col + i))
                    break
                } else {
                    break
                }
            }
        }

        var bottomRightDiagonal: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= col + i && col + i < 8 && 0 <= row + i && row + i < 8 {
                if board.getPiece(row: row + i, col: col + i) == nil {
                    bottomRightDiagonal.append((row + i, col + i))
                } else if let piece = board.getPiece(row: row + i, col: col + i), piece.color != self.color {
                    bottomRightDiagonal.append((row + i, col + i))
                    break
                } else {
                    break
                }
            }
        }

        var leftHorizontal: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= col - i && col - i < 8 {
                if board.getPiece(row: row, col: col - i) == nil {
                    leftHorizontal.append((row, col - i))
                } else if let piece = board.getPiece(row: row, col: col - i), piece.color != self.color {
                    leftHorizontal.append((row, col - i))
                    break
                } else {
                    break
                }
            }
        }

        var rightHorizontal: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= col + i && col + i < 8 {
                if board.getPiece(row: row, col: col + i) == nil {
                    rightHorizontal.append((row, col + i))
                } else if let piece = board.getPiece(row: row, col: col + i), piece.color != self.color {
                    rightHorizontal.append((row, col + i))
                    break
                } else {
                    break
                }
            }
        }

        var verticalTop: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= row - i && row - i < 8 {
                if board.getPiece(row: row - i, col: col) == nil {
                    verticalTop.append((row - i, col))
                } else if let piece = board.getPiece(row: row - i, col: col), piece.color != self.color {
                    verticalTop.append((row - i, col))
                    break
                } else {
                    break
                }
            }
        }

        var verticalDown: [(Int, Int)] = []
        for i in 1..<8 {
            if 0 <= row + i && row + i < 8 {
                if board.getPiece(row: row + i, col: col) == nil {
                    verticalDown.append((row + i, col))
                } else if let piece = board.getPiece(row: row + i, col: col), piece.color != self.color {
                    verticalDown.append((row + i, col))
                    break
                } else {
                    break
                }
            }
        }

        self.legalMoves = topLeftDiagonal + topRightDiagonal + bottomLeftDiagonal + bottomRightDiagonal + leftHorizontal + rightHorizontal + verticalTop + verticalDown
    }
    
    override func calculateCaptures(board: Board) {
        var captures: [(Int, Int)] = []
        for move in self.legalMoves {
            if let piece = board.getPiece(row: move.0, col: move.1), piece.color != self.color {
                captures.append(move)
            }
        }
        self.legalCaptures = captures
    }
    
    override func validateMoves(board: Board) {
        var moves: [(Int, Int)] = []
        for move in self.legalMoves {
            let tempBoard = board.deepCopy()
            let tempPiece = self.copy()
            if !CheckConditions(board: tempBoard, piece: tempPiece, move: move).validateMove() {
                moves.append(move)
            }
        }
        self.legalMoves = moves
    }
}

class Pawn: GamePiece {
    var isEnPassant: Bool = false
    var enPassantPosition: (Int, Int) = (-1, -1)
    
    init(row: Int, col: Int, color: String) {
        super.init(row: row, col: col, color: color, pieceCoordinates: "", pieceType: "pawn")
        self.img = UIImage(named: getImagePath())
        self.points = 1
    }
    
    required init(copying piece: GamePiece) {
        let pawn = piece as! Pawn
        super.init(copying: pawn)
    }
    
    override func copy() -> Pawn {
        return Pawn(copying: self)
    }
    override func calculateMoves(board: Board) {
        let (row, col) = self.position
        var pawnMoves: [(Int, Int)] = []
        // check for en passant for white
        if (row == 3 && self.color == "white") || (row == 4 && self.color == "black") {
            if let log = board.moveLog.last, log.piece.pieceType == "pawn" && log.piece.color != self.color && abs(log.oldPosition.0 - log.newPosition.0) == 2 && log.newPosition.0 == self.position.0 && abs(log.newPosition.1 - self.position.1) == 1 {
                self.isEnPassant = true
                self.enPassantPosition = (log.piece.position.0, log.piece.position.1)
                if self.color == "white" {
                    pawnMoves.append((log.piece.position.0 - 1, log.piece.position.1))
                } else {
                    pawnMoves.append((log.piece.position.0 + 1, log.piece.position.1))
                }
            }
            else {
                self.isEnPassant = false
                self.enPassantPosition = (-1, -1)
            }
        }
        else {
            self.isEnPassant = false
            self.enPassantPosition = (-1, -1)
        }

        if self.color == "white" {
            if 0 <= row - 1 && row - 1 < 8 && board.getPiece(row: row - 1, col: col) == nil {
                pawnMoves.append((row - 1, col))
            }
            if row == 6 && board.getPiece(row: row - 1, col: col) == nil && board.getPiece(row: row - 2, col: col) == nil {
                pawnMoves.append((row - 2, col))
            }
            // Capture moves for the white pawn
            if 0 <= row - 1 && row - 1 < 8 && 0 <= col - 1 && col - 1 < 8,
                let piece = board.getPiece(row: row - 1, col: col - 1), piece.color != self.color {
                pawnMoves.append((row - 1, col - 1))
            }
            if 0 <= row - 1 && row - 1 < 8 && 0 <= col + 1 && col + 1 < 8,
                let piece = board.getPiece(row: row - 1, col: col + 1), piece.color != self.color {
                pawnMoves.append((row - 1, col + 1))
            }
        } else {
            if 0 <= row + 1 && row + 1 < 8 && board.getPiece(row: row + 1, col: col) == nil {
                pawnMoves.append((row + 1, col))
            }
            if row == 1 && board.getPiece(row: row + 1, col: col) == nil && board.getPiece(row: row + 2, col: col) == nil {
                pawnMoves.append((row + 2, col))
            }
            // Capture moves for the black pawn
            if 0 <= row + 1 && row + 1 < 8 && 0 <= col - 1 && col - 1 < 8,
                let piece = board.getPiece(row: row + 1, col: col - 1), piece.color != self.color {
                pawnMoves.append((row + 1, col - 1))
            }
            if 0 <= row + 1 && row + 1 < 8 && 0 <= col + 1 && col + 1 < 8,
                let piece = board.getPiece(row: row + 1, col: col + 1), piece.color != self.color {
                pawnMoves.append((row + 1, col + 1))
            }
        }
        self.legalMoves = pawnMoves
    }

    
    override func calculateCaptures(board: Board) {
        var captures: [(Int, Int)] = []
        for move in self.legalMoves {
            if move.0 == self.position.0 {
                continue
            }
            if 0 <= move.0 && move.0 < 8 && 0 <= move.1 && move.1 < 8,
                let piece = board.getPiece(row: move.0, col: move.1), piece.color != self.color {
                captures.append(move)
            }
        }
        self.legalCaptures = captures
    }
    
    override func validateMoves(board: Board) {
        var moves: [(Int, Int)] = []
        for move in self.legalMoves {
            let tempBoard = board.deepCopy()
            let tempPiece = self.copy()
            if !CheckConditions(board: tempBoard, piece: tempPiece, move: move).validateMove() {
                moves.append(move)
            }
        }
        self.legalMoves = moves
    }
    
    func enPessant() -> Bool {
        return self.isEnPassant
    }
}

class King: GamePiece {
    init(row: Int, col: Int, color: String) {
        super.init(row: row, col: col, color: color, pieceCoordinates: "K", pieceType: "king")
        self.img = UIImage(named: getImagePath())
        self.points = -1
    }
    
    required init(copying piece: GamePiece) {
        let king = piece as! King
        super.init(copying: king)
    }
    
    override func copy() -> King {
        return King(copying: self)
    }
    
    override func calculateMoves(board: Board) {
        let (row, col) = self.position
        if !self.pieceMoved && self.position != self.originalPosition {
            self.pieceMoved = true
        }
        
        var kingMoves: [(Int, Int)] = []
        
        for i in -1..<2 {
            for j in -1..<2 {
                if 0 <= row + i && row + i < 8 && 0 <= col + j && col + j < 8 && (i != 0 || j != 0) {
                    let piece = board.getPiece(row: row + i, col: col + j)
                    if piece == nil || (piece != nil && piece?.color != self.color) {
                        kingMoves.append((row + i, col + j))
                    }
                }
            }
        }

        if !self.pieceMoved {
            if self.color == "white" {
                if board.getPiece(row: 7, col: 5) == nil && board.getPiece(row: 7, col: 6) == nil {
                    if let rook = board.getPiece(row: 7, col: 7), rook.pieceType == "rook" && !rook.pieceMoved {
                        if !CheckConditions(board: board, piece: self).kingInCheckCastle(kingPath: [(7, 6), (7, 5)]) {
                            kingMoves.append((7, 5))
                            kingMoves.append((7, 6))
                        }
                    }
                }
                if board.getPiece(row: 7, col: 3) == nil && board.getPiece(row: 7, col: 2) == nil && board.getPiece(row: 7, col: 1) == nil {
                    if let rook = board.getPiece(row: 7, col: 0), rook.pieceType == "rook" && !rook.pieceMoved {
                        if !CheckConditions(board: board, piece: self).kingInCheckCastle(kingPath: [(7, 3), (7, 2), (7, 1)]) {
                            kingMoves.append((7, 3))
                            kingMoves.append((7, 2))
                        }
                    }
                }
            } else if self.color == "black" {
                if board.getPiece(row: 0, col: 5) == nil && board.getPiece(row: 0, col: 6) == nil {
                    if let rook = board.getPiece(row: 0, col: 7), rook.pieceType == "rook" && !rook.pieceMoved {
                        if !CheckConditions(board: board, piece: self).kingInCheckCastle(kingPath: [(0, 6), (0, 5)]) {
                            kingMoves.append((0, 5))
                            kingMoves.append((0, 6))
                        }
                    }
                }
                if board.getPiece(row: 0, col: 3) == nil && board.getPiece(row: 0, col: 2) == nil && board.getPiece(row: 0, col: 1) == nil {
                    if let rook = board.getPiece(row: 0, col: 0), rook.pieceType == "rook" && !rook.pieceMoved {
                        if !CheckConditions(board: board, piece: self).kingInCheckCastle(kingPath: [(0, 3), (0, 2), (0, 1)]) {
                            kingMoves.append((0, 3))
                            kingMoves.append((0, 2))
                        }
                    }
                }
            }
        }
        
        self.legalMoves = kingMoves
    }
    
    override func calculateCaptures(board: Board) {
        var captures: [(Int, Int)] = []
        for move in self.legalMoves {
            if let piece = board.getPiece(row: move.0, col: move.1), piece.color != self.color {
                captures.append(move)
            }
        }
        self.legalCaptures = captures
    }
    
    override func validateMoves(board: Board) {
        var moves: [(Int, Int)] = []
        
        let opposingKingPosition = board.getKingPosition(color: self.color == "white" ? "black" : "white")
        var opposingKingMoves: [(Int, Int)] = []
        
        for i in -1...1 {
            for j in -1...1 {
                opposingKingMoves.append((opposingKingPosition.0 + i, opposingKingPosition.1 + j))
            }
        }
        
        for move in self.legalMoves {
            if opposingKingMoves.contains(where: {$0 == move}) {
                continue
            }
            let tempBoard = board.deepCopy()
            let tempPiece = self.copy()
            if !CheckConditions(board: tempBoard, piece: tempPiece, move: move).validateMove() {
                moves.append(move)
            }
        }
        self.legalMoves = moves
    }
}
