//import Foundation
//
//class UndoMove {
//    var board: Board
//    var moveLog: [MoveLog]
//    var lastMove: MoveLog
//    var piece: GamePiece
//    var oldPosition: Position
//    var newPosition: Position
//    var capturedPiece: GamePiece?
//    var isPromotion: Bool
//    var isCastle: Bool
//    var isEnPassant: Bool
//    var originalPawn: GamePiece?
//    var distinguish: Bool
//    
//    init(board: Board) {
//        self.board = board
//        self.moveLog = self.board.getMoveLog()
//        self.lastMove = self.board.moveLog.removeLast()
//        self.board.undoneMoves.addMove(move: self.lastMove)
//        
//        self.piece = self.lastMove.piece
//        self.oldPosition = self.lastMove.oldPosition
//        self.newPosition = self.lastMove.newPosition
//        self.capturedPiece = self.lastMove.capturedPiece
//        
//        self.isPromotion = self.lastMove.isPromotion
//        self.isCastle = self.lastMove.isCastle
//        self.isEnPassant = self.lastMove.isEnPassant
//        self.originalPawn = self.lastMove.originalPawn
//        
//        self.distinguish = self.lastMove.duplicate
//    }
//
//    func undo() {
////        self.board.moveLog.removeLast()
////        if let capturedPiece = self.capturedPiece {
////            self.board.capturedPieces.undoCapturedPiece(capturedPiece: capturedPiece)
////        }
//        if self.isCastle {
//            var rook: GamePiece?
//            // kingside castle undo
//            if self.newPosition.y == 6 {
//                rook = self.board.getPiece(position: Position(x: self.newPosition.x, y: self.newPosition.y - 1))
//                guard let rook = rook else {
//                    fatalError("Rook not found for kingside castle undo")
//                }
//                self.board[self.newPosition.x, 7] = rook
//                self.board[self.newPosition.x, self.newPosition.y - 1] = nil
//                rook.position = Position(x: self.newPosition.x, y: 7)
//            } else {
//                rook = self.board.getPiece(position: Position(x: self.newPosition.x, y: self.newPosition.y + 1))
//                guard let rook = rook else {
//                    fatalError("Rook not found for queenside castle undo")
//                }
//                self.board[self.newPosition.x, 0] = rook
//                self.board[self.newPosition.x, self.newPosition.y + 1] = nil
//                rook.position = Position(x: self.newPosition.x, y: 0)
//            }
//            self.board[self.oldPosition.x, self.oldPosition.y] = self.piece
//            self.board[self.newPosition.x, self.newPosition.y] = nil
//            self.piece.position = self.oldPosition
//            rook?.pieceMoved = false
//            self.piece.pieceMoved = false
//        }
//        else if self.isPromotion {
//            self.board[self.newPosition.x, self.newPosition.y] = self.capturedPiece
//            self.board[self.oldPosition.x, self.oldPosition.y] = self.originalPawn
//            if let pawn = self.originalPawn {
//                pawn.position = oldPosition
//            }
//            if let captured = self.capturedPiece {
//                captured.position = newPosition
//            }
//        } else if self.isEnPassant {
//            // Correctly restoring the captured pawn
//            self.board[self.oldPosition.x, self.oldPosition.y] = self.piece
//            self.board[self.newPosition.x, self.newPosition.y] = nil
//            self.piece.position = self.oldPosition
//            
//            let capturedRow = self.oldPosition.x
//            let capturedCol = self.newPosition.y
//            self.board[capturedRow, capturedCol] = self.capturedPiece
//            if let capturedPiece = self.capturedPiece {
//                capturedPiece.position = Position(x: capturedRow, y: capturedCol)
//            }
//        }
//        else {
//            self.board[self.newPosition.x, self.newPosition.y] = self.capturedPiece
//            self.board[self.oldPosition.x, self.oldPosition.y] = self.piece
//            
//            self.piece.position = oldPosition
//            if let captured = self.capturedPiece {
//                captured.position = newPosition
//            }
//        }
//        
//        self.piece.legalMoves = self.piece.setLegalMoves(board: self.board)
//        self.piece.legalCaptures = self.piece.getLegalCaptures(board: self.board)
//        
//        if self.piece.pieceType == "rook" {
//            var count = 0
//            
//            for attr in self.moveLog {
//                if attr.piece.pieceType == "rook" && attr.piece.id == self.piece.id {
//                    count += 1
//                }
//            }
//            if count == 0 {
//                self.piece.pieceMoved = false
//            }
//        }
//        
//        if self.piece.pieceType == "king" {
//            if self.piece.color == "white" {
//                self.board.whiteKingPosition = self.oldPosition
//            }
//            else {
//                self.board.blackKingPosition = self.oldPosition
//            }
//        }
//        
//
//    }
//}
