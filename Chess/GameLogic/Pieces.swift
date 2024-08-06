import UIKit

class GamePiece: Hashable {
    var legalMoves: Set<Position> = Set()
    var legalCaptures: Set<Position> = Set()
    var img: UIImage?
    let originalPosition: Position
    var position: Position
    let color: String
    var pieceType: String
    var pieceMoved = false
    var pieceCoordinates: String
    var id: String?
    var points = 0
    
    init(position: Position, color: String, pieceCoordinates: String, pieceType: String) {
        self.originalPosition = position
        self.position = position
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
    
    func setLegalMoves(board: Board) -> Set<Position> {
        calculateMoves(board: board)
        return legalMoves
    }
    
    @discardableResult
    func getLegalMoves(board: Board) -> Set<Position> {
        calculateMoves(board: board)
        return legalMoves
    }
    
    func getLegalCaptures(board: Board) -> Set<Position> {
        calculateCaptures(board: board)
        return legalCaptures
    }
    
    func validateLegalMoves(board: Board) -> Set<Position> {
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
    init(position: Position, color: String, id: String) {
        super.init(position: position, color: color, pieceCoordinates: color == "white" ? "R" : "r", pieceType: "rook")
        self.id = id
        self.img = UIImage(named: getImagePath())
        self.points = 5
    }
    
    required init(copying piece: GamePiece) {
        let rook = piece as! Rook
        super.init(copying: rook)
        rook.id = self.id
        rook.img = self.img
        rook.points = self.points
    }

    override func copy() -> Rook {
        return Rook(copying: self)
    }
    
    override func calculateMoves(board: Board) {
        let (row, col) = self.position.destructure()
        if !self.pieceMoved && self.position != self.originalPosition {
            self.pieceMoved = true
        }
        
        var leftHorizontal: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= col - i && col - i < 8 {
                if board.getPiece(position: Position(x: row, y: col - i)) == nil {
                    leftHorizontal.insert(Position(x: row, y: col - i))
                } else if board.getPiece(position: Position(x: row, y: col - i))?.color != self.color {
                    leftHorizontal.insert(Position(x: row, y: col - i))
                    break
                } else {
                    break
                }
            }
        }
        
        var rightHorizontal: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= col + i && col + i < 8 {
                if board.getPiece(position: Position(x: row, y: col + i)) == nil {
                    rightHorizontal.insert(Position(x: row, y: col + i))
                } else if board.getPiece(position: Position(x: row, y: col + i))?.color != self.color {
                    rightHorizontal.insert(Position(x: row, y: col + i))
                    break
                } else {
                    break
                }
            }
        }
        
        var verticalTop: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= row - i && row - i < 8 {
                if board.getPiece(position: Position(x: row - i, y: col)) == nil {
                    verticalTop.insert(Position(x: row - i, y: col))
                } else if board.getPiece(position: Position(x: row - i, y: col))?.color != self.color {
                    verticalTop.insert(Position(x: row - i, y: col))
                    break
                } else {
                    break
                }
            }
        }
        
        var verticalDown: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= row + i && row + i < 8 {
                if board.getPiece(position: Position(x: row + i, y: col)) == nil {
                    verticalDown.insert(Position(x: row + i, y: col))
                } else if board.getPiece(position: Position(x: row + i, y: col))?.color != self.color {
                    verticalDown.insert(Position(x: row + i, y: col))
                    break
                } else {
                    break
                }
            }
        }
        
        self.legalMoves = leftHorizontal.union(rightHorizontal).union(verticalTop).union(verticalDown)
    }
    
    override func calculateCaptures(board: Board) {
        var captures: Set<Position> = Set()
        for move in self.legalMoves {
            if let piece = board.getPiece(position: Position(x: move.x, y: move.y)), piece.color != self.color {
                captures.insert(Position(x: move.x, y: move.y))
            }
        }
        self.legalCaptures = captures
    }
    
    override func validateMoves(board: Board) {
        var moves: Set<Position> = Set()
        for move in self.legalMoves {
            let tempBoard = board.deepCopy()
            let tempPiece = self.copy()
            if !CheckConditions(board: tempBoard, piece: tempPiece, move: move).validateMove() {
                moves.insert(move)
            }
        }
        self.legalMoves = moves
    }
}

class Knight: GamePiece {
    init(position: Position, color: String) {
        super.init(position: position, color: color, pieceCoordinates: color == "white" ? "N" : "n", pieceType: "knight")
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
        let (row, col) = self.position.destructure()
        let moves = [
            Position(x: row - 2, y: col - 1), Position(x: row - 1, y: col - 2),
            Position(x: row + 1, y: col - 2), Position(x: row + 2, y: col - 1),
            Position(x: row + 2, y: col + 1), Position(x: row + 1, y: col + 2),
            Position(x: row - 1, y: col + 2), Position(x: row - 2, y: col + 1)
        ]
        var knightMoves: Set<Position> = Set()
        for move in moves {
            if move.x >= 0 && move.x < 8 && move.y >= 0 && move.y < 8 {
                if board.getPiece(position: Position(x: move.x, y: move.y)) == nil {
                    knightMoves.insert(move)
                } else if let piece = board.getPiece(position: Position(x: move.x, y: move.y)), piece.color != self.color {
                    knightMoves.insert(move)
                }
            }
        }
        self.legalMoves = knightMoves
    }
    
    override func calculateCaptures(board: Board) {
        var captures: Set<Position> = Set()
        for move in self.legalMoves {
            if let piece = board.getPiece(position: Position(x: move.x, y: move.y)), piece.color != self.color {
                captures.insert(move)
            }
        }
        self.legalCaptures = captures
    }
    
    override func validateMoves(board: Board) {
        var moves: Set<Position> = Set()
        for move in self.legalMoves {
            let tempBoard = board.deepCopy()
            let tempPiece = self.copy()
            if !CheckConditions(board: tempBoard, piece: tempPiece, move: move).validateMove() {
                moves.insert(move)
            }
        }
        self.legalMoves = moves
    }
}

class Bishop: GamePiece {
    init(position: Position, color: String) {
        super.init(position: position, color: color, pieceCoordinates: color == "white" ? "B" : "b", pieceType: "bishop")
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
        let (row, col) = self.position.destructure()
        var topLeftDiagonal: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= col - i && col - i < 8 && 0 <= row - i && row - i < 8 {
                if board.getPiece(position: Position(x: row - i, y: col - i)) == nil {
                    topLeftDiagonal.insert(Position(x: row - i, y: col - i))
                } else if let piece = board.getPiece(position: Position(x: row - i, y: col - i)), piece.color != self.color {
                    topLeftDiagonal.insert(Position(x: row - i, y: col - i))
                    break
                } else {
                    break
                }
            }
        }

        var bottomLeftDiagonal: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= col - i && col - i < 8 && 0 <= row + i && row + i < 8 {
                if board.getPiece(position: Position(x: row + i, y: col - i)) == nil {
                    bottomLeftDiagonal.insert(Position(x: row + i, y: col - i))
                } else if let piece = board.getPiece(position: Position(x: row + i, y: col - i)), piece.color != self.color {
                    bottomLeftDiagonal.insert(Position(x: row + i, y: col - i))
                    break
                } else {
                    break
                }
            }
        }

        var topRightDiagonal: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= col + i && col + i < 8 && 0 <= row - i && row - i < 8 {
                if board.getPiece(position: Position(x: row - i, y: col + i)) == nil {
                    topRightDiagonal.insert(Position(x: row - i, y: col + i))
                } else if let piece = board.getPiece(position: Position(x: row - i, y: col + i)), piece.color != self.color {
                    topRightDiagonal.insert(Position(x: row - i, y: col + i))
                    break
                } else {
                    break
                }
            }
        }

        var bottomRightDiagonal: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= col + i && col + i < 8 && 0 <= row + i && row + i < 8 {
                if board.getPiece(position: Position(x: row + i, y: col + i)) == nil {
                    bottomRightDiagonal.insert(Position(x: row + i, y: col + i))
                } else if let piece = board.getPiece(position: Position(x: row + i, y: col + i)), piece.color != self.color {
                    bottomRightDiagonal.insert(Position(x: row + i, y: col + i))
                    break
                } else {
                    break
                }
            }
        }

        self.legalMoves = topLeftDiagonal.union(topRightDiagonal).union(bottomLeftDiagonal).union(bottomRightDiagonal)
    }
    
    override func calculateCaptures(board: Board) {
        var captures: Set<Position> = Set()
        for move in self.legalMoves {
            if let piece = board.getPiece(position: Position(x: move.x, y: move.y)), piece.color != self.color {
                captures.insert(move)
            }
        }
        self.legalCaptures = captures
    }
    
    override func validateMoves(board: Board) {
        var moves: Set<Position> = Set()
        for move in self.legalMoves {
            let tempBoard = board.deepCopy()
            let tempPiece = self.copy()
            if !CheckConditions(board: tempBoard, piece: tempPiece, move: move).validateMove() {
                moves.insert(move)
            }
        }
        self.legalMoves = moves
    }
}

class Queen: GamePiece {
    init(position: Position, color: String) {
        super.init(position: position, color: color, pieceCoordinates: color == "white" ? "Q" : "q", pieceType: "queen")
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
        let (row, col) = self.position.destructure()
        var topLeftDiagonal: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= col - i && col - i < 8 && 0 <= row - i && row - i < 8 {
                if board.getPiece(position: Position(x: row - i, y: col - i)) == nil {
                    topLeftDiagonal.insert(Position(x: row - i, y: col - i))
                } else if let piece = board.getPiece(position: Position(x: row - i, y: col - i)), piece.color != self.color {
                    topLeftDiagonal.insert(Position(x: row - i, y: col - i))
                    break
                } else {
                    break
                }
            }
        }

        var bottomLeftDiagonal: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= col - i && col - i < 8 && 0 <= row + i && row + i < 8 {
                if board.getPiece(position: Position(x: row + i, y: col - i)) == nil {
                    bottomLeftDiagonal.insert(Position(x: row + i, y: col - i))
                } else if let piece = board.getPiece(position: Position(x: row + i, y: col - i)), piece.color != self.color {
                    bottomLeftDiagonal.insert(Position(x: row + i, y: col - i))
                    break
                } else {
                    break
                }
            }
        }

        var topRightDiagonal: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= col + i && col + i < 8 && 0 <= row - i && row - i < 8 {
                if board.getPiece(position: Position(x: row - i, y: col + i)) == nil {
                    topRightDiagonal.insert(Position(x: row - i, y: col + i))
                } else if let piece = board.getPiece(position: Position(x: row - i, y: col + i)), piece.color != self.color {
                    topRightDiagonal.insert(Position(x: row - i, y: col + i))
                    break
                } else {
                    break
                }
            }
        }

        var bottomRightDiagonal: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= col + i && col + i < 8 && 0 <= row + i && row + i < 8 {
                if board.getPiece(position: Position(x: row + i, y: col + i)) == nil {
                    bottomRightDiagonal.insert(Position(x: row + i, y: col + i))
                } else if let piece = board.getPiece(position: Position(x: row + i, y: col + i)), piece.color != self.color {
                    bottomRightDiagonal.insert(Position(x: row + i, y: col + i))
                    break
                } else {
                    break
                }
            }
        }

        var leftHorizontal: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= col - i && col - i < 8 {
                if board.getPiece(position: Position(x: row, y: col - i)) == nil {
                    leftHorizontal.insert(Position(x: row, y: col - i))
                } else if board.getPiece(position: Position(x: row, y: col - i))?.color != self.color {
                    leftHorizontal.insert(Position(x: row, y: col - i))
                    break
                } else {
                    break
                }
            }
        }
        
        var rightHorizontal: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= col + i && col + i < 8 {
                if board.getPiece(position: Position(x: row, y: col + i)) == nil {
                    rightHorizontal.insert(Position(x: row, y: col + i))
                } else if board.getPiece(position: Position(x: row, y: col + i))?.color != self.color {
                    rightHorizontal.insert(Position(x: row, y: col + i))
                    break
                } else {
                    break
                }
            }
        }
        
        var verticalTop: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= row - i && row - i < 8 {
                if board.getPiece(position: Position(x: row - i, y: col)) == nil {
                    verticalTop.insert(Position(x: row - i, y: col))
                } else if board.getPiece(position: Position(x: row - i, y: col))?.color != self.color {
                    verticalTop.insert(Position(x: row - i, y: col))
                    break
                } else {
                    break
                }
            }
        }
        
        var verticalDown: Set<Position> = Set()
        for i in 1..<8 {
            if 0 <= row + i && row + i < 8 {
                if board.getPiece(position: Position(x: row + i, y: col)) == nil {
                    verticalDown.insert(Position(x: row + i, y: col))
                } else if board.getPiece(position: Position(x: row + i, y: col))?.color != self.color {
                    verticalDown.insert(Position(x: row + i, y: col))
                    break
                } else {
                    break
                }
            }
        }

        self.legalMoves = topLeftDiagonal.union(topRightDiagonal).union(bottomLeftDiagonal).union(bottomRightDiagonal).union(leftHorizontal).union(rightHorizontal).union(verticalTop).union(verticalDown)
    }
    
    override func calculateCaptures(board: Board) {
        var captures: Set<Position> = Set()
        for move in self.legalMoves {
            if let piece = board.getPiece(position: Position(x: move.x, y: move.y)), piece.color != self.color {
                captures.insert(move)
            }
        }
        self.legalCaptures = captures
    }
    
    override func validateMoves(board: Board) {
        var moves: Set<Position> = Set()
        for move in self.legalMoves {
            let tempBoard = board.deepCopy()
            let tempPiece = self.copy()
            if !CheckConditions(board: tempBoard, piece: tempPiece, move: move).validateMove() {
                moves.insert(move)
            }
        }
        self.legalMoves = moves
    }
}

class Pawn: GamePiece {
    var isEnPassant: Bool = false
    var enPassantPosition: Position = Position(x: -1, y: -1)
    
    init(position: Position, color: String) {
        super.init(position: position, color: color, pieceCoordinates: color == "white" ? "P" : "p", pieceType: "pawn")
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
        let (row, col) = self.position.destructure()
        var pawnMoves: Set<Position> = Set()
        // check for en passant for white
        if (row == 3 && self.color == "white") || (row == 4 && self.color == "black") {
            if let log = board.moveLog.last, log.piece.pieceType == "pawn" && log.piece.color != self.color && abs(log.oldPosition.x - log.newPosition.x) == 2 && log.newPosition.x == self.position.x && abs(log.newPosition.y - self.position.y) == 1 {
                self.isEnPassant = true
                self.enPassantPosition = Position(x: log.piece.position.x, y: log.piece.position.y)
                if self.color == "white" {
                    pawnMoves.insert(Position(x: log.piece.position.x - 1, y: log.piece.position.y))
                } else {
                    pawnMoves.insert(Position(x: log.piece.position.x + 1, y: log.piece.position.y))
                }
            }
            else {
                self.isEnPassant = false
                self.enPassantPosition = Position(x: -1, y: -1)
            }
        }
        else {
            self.isEnPassant = false
            self.enPassantPosition = Position(x: -1, y: -1)
        }

        if self.color == "white" {
            if 0 <= row - 1 && row - 1 < 8 && board.getPiece(position: Position(x: row - 1, y: col)) == nil {
                pawnMoves.insert(Position(x: row - 1, y: col))
            }
            if row == 6 && board.getPiece(position: Position(x: row - 1, y: col)) == nil && board.getPiece(position: Position(x: row - 2, y: col)) == nil {
                pawnMoves.insert(Position(x: row - 2, y: col))
            }
            // Capture moves for the white pawn
            if 0 <= row - 1 && row - 1 < 8 && 0 <= col - 1 && col - 1 < 8,
                let piece = board.getPiece(position: Position(x: row - 1, y: col - 1)), piece.color != self.color {
                pawnMoves.insert(Position(x: row - 1, y: col - 1))
            }
            if 0 <= row - 1 && row - 1 < 8 && 0 <= col + 1 && col + 1 < 8,
                let piece = board.getPiece(position: Position(x: row - 1, y: col + 1)), piece.color != self.color {
                pawnMoves.insert(Position(x: row - 1, y: col + 1))
            }
        } else {
            if 0 <= row + 1 && row + 1 < 8 && board.getPiece(position: Position(x: row + 1, y: col)) == nil {
                pawnMoves.insert(Position(x: row + 1, y: col))
            }
            if row == 1 && board.getPiece(position: Position(x: row + 1, y: col)) == nil && board.getPiece(position: Position(x: row + 2, y: col)) == nil {
                pawnMoves.insert(Position(x: row + 2, y: col))
            }
            // Capture moves for the black pawn
            if 0 <= row + 1 && row + 1 < 8 && 0 <= col - 1 && col - 1 < 8,
                let piece = board.getPiece(position: Position(x: row + 1, y: col - 1)), piece.color != self.color {
                pawnMoves.insert(Position(x: row + 1, y: col - 1))
            }
            if 0 <= row + 1 && row + 1 < 8 && 0 <= col + 1 && col + 1 < 8,
                let piece = board.getPiece(position: Position(x: row + 1, y: col + 1)), piece.color != self.color {
                pawnMoves.insert(Position(x: row + 1, y: col + 1))
            }
        }
        self.legalMoves = pawnMoves
    }

    
    override func calculateCaptures(board: Board) {
        var captures: Set<Position> = Set()
        for move in self.legalMoves {
            if move.x == self.position.x {
                continue
            }
            if 0 <= move.x && move.x < 8 && 0 <= move.y && move.y < 8,
                let piece = board.getPiece(position: Position(x: move.x, y: move.y)), piece.color != self.color {
                captures.insert(move)
            }
        }
        self.legalCaptures = captures
    }
    
    override func validateMoves(board: Board) {
        var moves: Set<Position> = Set()
        for move in self.legalMoves {
            let tempBoard = board.deepCopy()
            let tempPiece = self.copy()
            if !CheckConditions(board: tempBoard, piece: tempPiece, move: move).validateMove() {
                moves.insert(move)
            }
        }
        self.legalMoves = moves
    }
    
    func enPessant() -> Bool {
        return self.isEnPassant
    }
}

class King: GamePiece {
    var canCastleKingSide: Bool = true
    var canCastleQueenSide: Bool = true
    
    init(position: Position, color: String) {
        super.init(position: position, color: color, pieceCoordinates: color == "white" ? "K" : "k", pieceType: "king")
        self.img = UIImage(named: getImagePath())
        self.points = -1
    }
    
    required init(copying piece: GamePiece) {
        let king = piece as! King
        super.init(copying: king)
        king.canCastleKingSide = self.canCastleKingSide
        king.canCastleQueenSide = self.canCastleQueenSide
    }
    
    override func copy() -> King {
        return King(copying: self)
    }
    
    override func calculateMoves(board: Board) {
        let (row, col) = self.position.destructure()
        if !self.pieceMoved && self.position != self.originalPosition {
            self.pieceMoved = true
        }
        
        var kingMoves: Set<Position> = Set()
        
        for i in -1..<2 {
            for j in -1..<2 {
                if 0 <= row + i && row + i < 8 && 0 <= col + j && col + j < 8 && (i != 0 || j != 0) {
                    let piece = board.getPiece(position: Position(x: row + i, y: col + j))
                    if piece == nil || (piece != nil && piece?.color != self.color) {
                        kingMoves.insert(Position(x: row + i, y: col + j))
                    }
                }
            }
        }

        if !self.pieceMoved {
            if self.color == "white" {
                if board.getPiece(position: Position(x: 7, y: 5)) == nil && board.getPiece(position: Position(x: 7, y: 6)) == nil {
                    if let rook = board.getPiece(position: Position(x: 7, y: 7)), rook.pieceType == "rook" && !rook.pieceMoved {
                        if !CheckConditions(board: board, piece: self).kingInCheckCastle(kingPath: Set([Position(x: 7, y: 6), Position(x: 7, y: 5)])) {
                            kingMoves.insert(Position(x: 7, y: 5))
                            kingMoves.insert(Position(x: 7, y: 6))
                            self.canCastleKingSide = true
                        } else {
                            self.canCastleKingSide = false
                        }
                    }
                }
                if board.getPiece(position: Position(x: 7, y: 3)) == nil && board.getPiece(position: Position(x: 7, y: 2)) == nil && board.getPiece(position: Position(x: 7, y: 1)) == nil {
                    if let rook = board.getPiece(position: Position(x: 7, y: 0)), rook.pieceType == "rook" && !rook.pieceMoved {
                        if !CheckConditions(board: board, piece: self).kingInCheckCastle(kingPath: Set([Position(x: 7, y: 3), Position(x: 7, y: 2), Position(x: 7, y: 1)])) {
                            kingMoves.insert(Position(x: 7, y: 3))
                            kingMoves.insert(Position(x: 7, y: 2))
                            self.canCastleQueenSide = true
                        } else {
                            self.canCastleQueenSide = false
                        }
                    }
                }
            } else if self.color == "black" {
                if board.getPiece(position: Position(x: 0, y: 5)) == nil && board.getPiece(position: Position(x: 0, y: 6)) == nil {
                    if let rook = board.getPiece(position: Position(x: 0, y: 7)), rook.pieceType == "rook" && !rook.pieceMoved {
                        if !CheckConditions(board: board, piece: self).kingInCheckCastle(kingPath: Set([Position(x: 0, y: 6), Position(x: 0, y: 5)])) {
                            kingMoves.insert(Position(x: 0, y: 5))
                            kingMoves.insert(Position(x: 0, y: 6))
                            self.canCastleKingSide = true
                        } else {
                            self.canCastleKingSide = false
                        }
                    }
                }
                if board.getPiece(position: Position(x: 0, y: 3)) == nil && board.getPiece(position: Position(x: 0, y: 2)) == nil && board.getPiece(position: Position(x: 0, y: 1)) == nil {
                    if let rook = board.getPiece(position: Position(x: 0, y: 0)), rook.pieceType == "rook" && !rook.pieceMoved {
                        if !CheckConditions(board: board, piece: self).kingInCheckCastle(kingPath: Set([Position(x: 0, y: 3), Position(x: 0, y: 2), Position(x: 0, y: 1)])) {
                            kingMoves.insert(Position(x: 0, y: 3))
                            kingMoves.insert(Position(x: 0, y: 2))
                            self.canCastleQueenSide = true
                        } else {
                            self.canCastleQueenSide = false
                        }
                    }
                }
            }
        }
        
        self.legalMoves = kingMoves
    }
    
    override func calculateCaptures(board: Board) {
        var captures: Set<Position> = Set()
        for move in self.legalMoves {
            if let piece = board.getPiece(position: Position(x: move.x, y: move.y)), piece.color != self.color {
                captures.insert(move)
            }
        }
        self.legalCaptures = captures
    }
    
    override func validateMoves(board: Board) {
        var moves: Set<Position> = Set()
        
        let opposingKingPosition = board.getKingPosition(color: self.color == "white" ? "black" : "white")
        var opposingKingMoves: Set<Position> = Set()
        
        for i in -1...1 {
            for j in -1...1 {
                opposingKingMoves.insert(Position(x: opposingKingPosition.x + i, y: opposingKingPosition.y + j))
            }
        }
        
        for move in self.legalMoves {
            if opposingKingMoves.contains(where: {$0 == move}) {
                continue
            }
            let tempBoard = board.deepCopy()
            let tempPiece = self.copy()
            if !CheckConditions(board: tempBoard, piece: tempPiece, move: move).validateMove() {
                moves.insert(move)
            }
        }
        self.legalMoves = moves
    }
}
