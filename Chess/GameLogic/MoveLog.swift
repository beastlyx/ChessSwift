
class MoveLog {
    var board: Board
    var piece: GamePiece
//    var moveLog: [MoveLog]
//    var capturedPieces: CapturedPieces
    var capturedPiece: GamePiece?
    var oldPosition: (Int, Int)
    var newPosition: (Int, Int)
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
    
    init(board: Board, piece: GamePiece, capturedPiece: GamePiece?, oldPosition: (Int, Int), newPosition: (Int, Int), isPromotion: Bool, isCastle: Bool, isEnPassant: Bool, originalPawn: GamePiece?) {
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
        self.duplicate = self.checkForDuplicatMoves()
    }
    
    func logMove() {
        let coordinate = ""
        let oldRow = self.rowCoordinates[self.oldPosition.0]
        let oldCol = self.columnCoordinates[self.oldPosition.1]
        let newCol = self.columnCoordinates[self.newPosition.1]
        let newRow = self.rowCoordinates[self.newPosition.0]
        
        if self.piece.pieceType == "pawn" {
            self.logMovePawn()
        }
        
        else if self.piece.pieceType == "king" && self.isCastle {
            self.logMoveCastle()
        }
        else if self.duplicate {
            let otherPosition = self.checkSameMove()
            if otherPosition.0 != self.oldPosition.0 {
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
            let toCol = self.columnCoordinates[self.newPosition.1]
            let toRow = self.rowCoordinates[self.newPosition.0]
            let coordinate = self.piece.pieceCoordinates
            
            if self.piece.pieceType == "pawn" {
                self.move = "\(toCol)\(toRow)\(self.kingInCheck)\(self.checkmate)"
            }
            else {
                self.move = "\(toCol)\(toRow)=\(coordinate)\(self.kingInCheck)\(self.checkmate)"
            }
        }
        else {
            let fromCol = self.columnCoordinates[self.oldPosition.1]
            let toCol = self.columnCoordinates[self.newPosition.1]
            let toRow = self.rowCoordinates[self.newPosition.0]
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
        if self.newPosition.1 == 6 {
            self.move = "0-0\(self.kingInCheck)\(self.checkmate)"
        }
        else {
            self.move = "0-0-0\(self.kingInCheck)\(self.checkmate)"
        }
    }
    
    func checkForDuplicatMoves() -> Bool {
        let otherPiecePosition = self.checkSameMove()
        if otherPiecePosition != (-1, -1) {
            if let otherPiece = self.board.getPiece(row: otherPiecePosition.0, col: otherPiecePosition.1) {
                let otherPieceMoves: [(Int, Int)] = otherPiece.setLegalMoves(board: self.board)
                let currentPieceMoves: [(Int, Int)] = self.piece.setLegalMoves(board: self.board)
                
                var uniqueMoves: [(Int, Int)] = []
                for move in otherPieceMoves {
                    if !uniqueMoves.contains(where: { $0 == move }) {
                        uniqueMoves.append(move)
                    }
                }
                for move in currentPieceMoves {
                    if !uniqueMoves.contains(where: { $0 == move }) {
                        uniqueMoves.append(move)
                    }
                }
                
                return uniqueMoves.contains(where: { $0 == self.newPosition })
            }
        }
        return false
    }
    
    func checkSameMove() -> (Int, Int) {
        if self.piece.pieceType == "pawn" {
            return (-1, -1)
        }
        let oldPos = self.oldPosition
        let newPos = self.newPosition
        for row in 0..<8 {
            for col in 0..<8 {
                if let duplicatePiece = self.board.getPiece(row: row, col: col), duplicatePiece.pieceType == self.piece.pieceType {
                    if duplicatePiece.color == self.piece.color && newPos != (row, col) && oldPos != (row, col) {
                        return (row, col)
                    }
                }
            }
        }
        return (-1, -1)
    }
    
    func addMove() {
        if self.capturedPiece != nil {
            self.capture = "x"
        }
        let tempBoard = self.board
        let kingPos = self.board.getKingPosition(color: self.piece.color == "white" ? "black" : "white")
        if let tempPiece = self.board.getPiece(row: kingPos.0, col: kingPos.1) {
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
        let copiedPiece = self.piece
        let copiedCapturedPiece = self.capturedPiece
        let copiedOriginalPawn = self.originalPawn
        
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
