
class MoveLog {
    var board: Board
    var piece: GamePiece
//    var moveLog: [MoveLog]
//    var capturedPieces: CapturedPieces
    var FEN: String = ""
    var capturedPiece: GamePiece?
    var oldPosition: Position
    var newPosition: Position
    var isPromotion: Bool
    var isCastle: Bool
    var isEnPassant: Bool
    var originalPawn: GamePiece?
    var columnCoordinates: [String] = ["a", "b", "c", "d", "e", "f", "g", "h"]
    var rowCoordinates: [String] = ["8", "7", "6", "5", "4", "3", "2", "1"]
    var duplicate: Bool = false
    var move: String = ""
    var capture: String = ""
    var kingInCheck: String = ""
    var isCheck: Bool = false
    var checkmate: String = ""
    var isCheckmate: Bool = false
    
    init(board: Board, piece: GamePiece, capturedPiece: GamePiece?, oldPosition: Position, newPosition: Position, isPromotion: Bool, isCastle: Bool, isEnPassant: Bool, originalPawn: GamePiece?) {
        self.board = board
//        self.moveLog = self.board.getMoveLog()
//        self.capturedPieces = self.board.capturedPieces
        self.piece = piece
        self.capturedPiece = capturedPiece
        self.originalPawn = originalPawn
        self.oldPosition = oldPosition
        self.newPosition = newPosition
        self.isPromotion = isPromotion
        self.isCastle = isCastle
        self.isEnPassant = isEnPassant
        self.duplicate = self.checkForDuplicateMoves()
        self.FEN = self.setFEN()
    }
    
    func setFEN() -> String {
        var fen = ""
        var castleRightWhiteKingSide = ""
        var castleRightWhiteQueenSide = ""
        var castleRightBlackKingSide = ""
        var castleRightBlackQueenSide = ""
        var enPassant = ""
        
        for row in 0..<8 {
            var empty = 0
            var colFEN = ""
            for col in 0..<8 {
                if let piece = board.getPiece(position: Position(x: row, y: col)) {
                    colFEN = empty == 0 ? colFEN + piece.pieceCoordinates : colFEN + String(empty) + piece.pieceCoordinates
                    empty = 0
                    
                    if piece.pieceType == "king" {
                        if let king = piece as? King {
                            if king.color == "white" {
                                castleRightWhiteKingSide = king.canCastleKingSide ? king.pieceCoordinates : ""
                                castleRightWhiteQueenSide = king.canCastleQueenSide ? "Q" : ""
                            } else {
                                castleRightBlackKingSide = king.canCastleKingSide ? king.pieceCoordinates : ""
                                castleRightBlackQueenSide = king.canCastleQueenSide ? "q" : ""
                            }
                        }
                    }
                    
                    if piece.pieceType == "pawn" && abs(self.oldPosition.x - self.newPosition.x) == 2 {
                        if piece.color == "white" {
                            enPassant += columnCoordinates[self.newPosition.y] + rowCoordinates[self.newPosition.x + 1] + " "
                        } else {
                            enPassant += columnCoordinates[self.newPosition.y] + rowCoordinates[self.newPosition.x - 1] + " "
                        }
                    }
                } else {
                    empty += 1
                }
            }
            if empty != 0 {
                fen += colFEN + String(empty) + "/"
            } else {
                fen += colFEN
                
                if row < 7 {
                    fen += "/"
                }
            }
        }
        
        fen += self.piece.color == "white" ? " b " : " w "

        if castleRightWhiteKingSide.isEmpty && castleRightWhiteQueenSide.isEmpty {
            fen += "- "
        } else if !castleRightWhiteKingSide.isEmpty || !castleRightWhiteQueenSide.isEmpty {
            fen += castleRightWhiteKingSide + castleRightWhiteQueenSide + " "
        } else if castleRightBlackKingSide.isEmpty && castleRightBlackQueenSide.isEmpty {
            fen += "- "
        } else if !castleRightBlackKingSide.isEmpty || !castleRightBlackQueenSide.isEmpty {
            fen += castleRightBlackKingSide + castleRightBlackQueenSide + " "
        }
        
        if enPassant.isEmpty {
            fen += "- "
        } else {
            fen += enPassant
        }
        
        fen += String(self.board.halfMove) + " " + String(self.board.fullMove)
        
        return fen
    }
    
    func logMove() {
        let coordinate = ""
        let oldRow = self.rowCoordinates[self.oldPosition.x]
        let oldCol = self.columnCoordinates[self.oldPosition.y]
        let newCol = self.columnCoordinates[self.newPosition.y]
        let newRow = self.rowCoordinates[self.newPosition.x]
        
        if self.piece.pieceType == "pawn" {
            self.logMovePawn()
        }
        
        else if self.piece.pieceType == "king" && self.isCastle {
            self.logMoveCastle()
        }
        else if self.duplicate {
            let otherPosition = self.checkSameMove()
            if otherPosition.x != self.oldPosition.x {
                self.move = "\(coordinate)\(oldRow)\(self.capture)\(newCol)\(newRow)\(self.kingInCheck)\(self.checkmate)"
            }
            else {
                self.move = "\(coordinate)\(oldCol)\(self.capture)\(newCol)\(newRow)\(self.kingInCheck)\(self.checkmate)"
            }
        }
        else {
            self.move = "\(coordinate)\(self.capture)\(newCol)\(newRow)\(self.kingInCheck)\(self.checkmate)"
        }
    }
    
    func logMovePawn() {
        if self.capturedPiece == nil {
            let toCol = self.columnCoordinates[self.newPosition.y]
            let toRow = self.rowCoordinates[self.newPosition.x]
            let coordinate = self.piece.pieceCoordinates
            
            if self.piece.pieceType == "pawn" {
                self.move = "\(toCol)\(toRow)\(self.kingInCheck)\(self.checkmate)"
            }
            else {
                self.move = "\(toCol)\(toRow)=\(coordinate)\(self.kingInCheck)\(self.checkmate)"
            }
        }
        else {
            let fromCol = self.columnCoordinates[self.oldPosition.y]
            let toCol = self.columnCoordinates[self.newPosition.y]
            let toRow = self.rowCoordinates[self.newPosition.x]
            let coordinate = self.piece.pieceCoordinates
            
            if self.piece.pieceType == "pawn" {
                if self.isEnPassant {
                    self.move = "\(fromCol)x\(toCol)\(toRow)e/p\(self.kingInCheck)\(self.checkmate)"
                }
                else {
                    self.move = "\(fromCol)x\(toCol)\(toRow)\(self.kingInCheck)\(self.checkmate)"
                }
            }
            else {
                self.move = "\(fromCol)x\(toCol)\(toRow)=\(coordinate)\(self.kingInCheck)\(self.checkmate)"
            }
        }
    }
    
    func logMoveCastle() {
        if self.newPosition.y == 6 {
            self.move = "0-0\(self.kingInCheck)\(self.checkmate)"
        }
        else {
            self.move = "0-0-0\(self.kingInCheck)\(self.checkmate)"
        }
    }
    
    func checkForDuplicateMoves() -> Bool {
        let otherPiecePosition = self.checkSameMove()
        if otherPiecePosition != Position(x: -1, y: -1) {
            if let otherPiece = self.board.getPiece(position: otherPiecePosition) {
                let otherPieceMoves: Set<Position> = otherPiece.setLegalMoves(board: self.board)
                let currentPieceMoves: Set<Position> = self.piece.setLegalMoves(board: self.board)
                
                var uniqueMoves: Set<Position> = Set()
                uniqueMoves = otherPieceMoves.union(currentPieceMoves)
                
                return uniqueMoves.contains(where: { $0 == self.newPosition })
            }
        }
        return false
    }
    
    func checkSameMove() -> Position {
        if self.piece.pieceType == "pawn" {
            return Position(x: -1, y: -1)
        }
        let oldPos = self.oldPosition
        let newPos = self.newPosition
        for row in 0..<8 {
            for col in 0..<8 {
                if let duplicatePiece = self.board.getPiece(position: Position(x: row, y: col)), duplicatePiece.pieceType == self.piece.pieceType {
                    if duplicatePiece.color == self.piece.color && newPos != Position(x: row, y: col) && oldPos != Position(x: row, y: col) {
                        return Position(x: row, y: col)
                    }
                }
            }
        }
        return Position(x: -1, y: -1)
    }
    
    func addMove() {
        if self.capturedPiece != nil {
            self.capture = "x"
        }
        let tempBoard = self.board
        let kingPos = self.board.getKingPosition(color: self.piece.color == "white" ? "black" : "white")
        if let tempPiece = self.board.getPiece(position: Position(x: kingPos.x, y: kingPos.y)) {
            let checkConditions = CheckConditions(board: tempBoard, piece: tempPiece)
            if checkConditions.kingInCheck() {
                self.kingInCheck = "+"
                self.isCheck = true
            }
            if checkConditions.checkmate() == "checkmate" {
                self.kingInCheck = ""
                self.checkmate = "#"
                self.isCheck = false
                self.isCheckmate = true
            }
        }
        self.logMove()
    }
    
    func getMove() -> MoveLog {
        return self
    }
    
    func getBoard() -> Board {
        return self.board
    }
    
    func copy() -> MoveLog {
        let copiedPiece = self.piece.copy()
        let copiedCapturedPiece = self.capturedPiece?.copy()
        let copiedOriginalPawn = self.originalPawn?.copy()
        
        var newMovelog = MoveLog(
            board: self.board,
            piece: copiedPiece,
            capturedPiece: copiedCapturedPiece,
            oldPosition: self.oldPosition,
            newPosition: self.newPosition,
            isPromotion: self.isPromotion,
            isCastle: self.isCastle,
            isEnPassant: self.isEnPassant,
            originalPawn: copiedOriginalPawn
        )
        
        newMovelog.move = self.move
        newMovelog.duplicate = self.duplicate
        newMovelog.capture = self.capture
        newMovelog.kingInCheck = self.kingInCheck
        newMovelog.isCheck = self.isCheck
        newMovelog.checkmate = self.checkmate
        newMovelog.isCheckmate = self.isCheckmate
        return newMovelog
    }
}
