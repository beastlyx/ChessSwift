import Foundation

class BoardState {
    var undoneMoves: [MoveLog]
    
    init() {
        self.undoneMoves = []
    }
    
    func addMove(move: MoveLog) {
        self.undoneMoves.insert(move, at: 0)
    }
    
    func getUndoneMoves() -> [MoveLog] {
        return self.undoneMoves
    }
    
    func redo(snapshot: Bool = false) {
        if undoneMoves.isEmpty {
            return
        }
        
        let lastMove = undoneMoves.remove(at: 0)
        lastMove.board.movePiece(piece: lastMove.piece, newPosition: lastMove.newPosition)
//        makeMove(piece: lastMove.piece, capturedPiece: lastMove.capturedPiece, fromPosition: lastMove.oldPosition, newPosition: lastMove.newPosition, isPromotion: lastMove.isPromotion, isCastle: lastMove.isCastle, isEnPassant: lastMove.isEnPassant, originalPawn: lastMove.originalPawn)
    }
    
    func reset() {
        self.undoneMoves.removeAll()
    }
}
//
////    func undoMove(board: Board) {
////        if self.completedMoves.isEmpty {
////            return
////        }
////        
////        let lastMove = self.completedMoves.removeLast()
////        undoneMoves.append(lastMove)
////
////        var board = lastMove.board
////        var piece = lastMove.piece
////        var oldPosition = lastMove.oldPosition
////        var newPosition = lastMove.newPosition
////        var capturedPiece = lastMove.capturedPiece
////        var isPromotion = lastMove.isPromotion
////        var isCastle = lastMove.isCastle
////        var isEnPassant = lastMove.isEnPassant
////        var originalPawn = lastMove.originalPawn
////        var distinguish = lastMove.duplicate
////        
////        if isCastle {
////            var rook: GamePiece
////            // kingside castle undo
////            if newPosition.1 == 6 {
////                rook = board.getPiece(row: newPosition.0, col: newPosition.1 - 1)!
////                board[newPosition.0, 7] = rook
////                board[newPosition.0, newPosition.1 - 1] = nil
////                rook.position = (newPosition.0, 7)
////            } else {
////                rook = board.getPiece(row: newPosition.0, col: newPosition.1 + 1)!
////                board[newPosition.0, 0] = rook
////                board[newPosition.0, newPosition.1 + 1] = nil
////                rook.position = (newPosition.0, 0)
////            }
////            board[oldPosition.0, oldPosition.1] = piece
////            board[newPosition.0, newPosition.1] = nil
////            piece.position = (oldPosition.0, oldPosition.1)
////            rook.pieceMoved = false
////            piece.pieceMoved = false
////        }
////        else if isPromotion {
////            board[newPosition.0, newPosition.1] = capturedPiece
////            board[oldPosition.0, oldPosition.1] = originalPawn
////            if let pawn = originalPawn {
////                pawn.position = (oldPosition.0, oldPosition.1)
////            }
////            if let captured = capturedPiece {
////                captured.position = (newPosition.0, newPosition.1)
////            }
////        } else if isEnPassant {
////            board[oldPosition.0, oldPosition.1] = piece
////            board[newPosition.0, newPosition.1] = nil
////            piece.position = oldPosition
////            
////            let capturedRow = oldPosition.0
////            let capturedCol = newPosition.1
////            board[capturedRow, capturedCol] = capturedPiece
////            if let capturedPiece = capturedPiece {
////                capturedPiece.position = (capturedRow, capturedCol)
////            }
////        }
////        else {
////            board[newPosition.0, newPosition.1] = capturedPiece
////            board[oldPosition.0, oldPosition.1] = piece
////            
////            piece.position = (oldPosition.0, oldPosition.1)
////            if let captured = capturedPiece {
////                captured.position = (newPosition.0, newPosition.1)
////            }
////        }
////        
////        piece.legalMoves = piece.setLegalMoves(board: board)
////        piece.legalCaptures = piece.getLegalCaptures(board: board)
////        
////        if piece.pieceType == "king" {
////            if piece.color == "white" {
////                board.whiteKingPosition = oldPosition
////            }
////            else {
////                board.blackKingPosition = oldPosition
////            }
////        }
////    }
////    
////    func redoMove(board: Board) {
////        if self.undoneMoves.isEmpty {
////            return
////        }
////        
////        let redoMove = self.undoneMoves.removeLast()
////        self.completedMoves.append(redoMove)
////        
////        var board = redoMove.board
////        var piece = redoMove.piece
////        var oldPosition = redoMove.oldPosition
////        var newPosition = redoMove.newPosition
////        var capturedPiece = redoMove.capturedPiece
////        var isPromotion = redoMove.isPromotion
////        var isCastle = redoMove.isCastle
////        var isEnPassant = redoMove.isEnPassant
////        var originalPawn = redoMove.originalPawn
////        var distinguish = redoMove.duplicate
////        
////        if isCastle {
////            var rook: GamePiece
////            // kingside castle undo
////            if newPosition.1 == 6 {
////                rook = board.getPiece(row: newPosition.0, col: newPosition.1 - 1)!
////                board[newPosition.0, 7] = rook
////                board[newPosition.0, newPosition.1 - 1] = nil
////                rook.position = (newPosition.0, 7)
////            } else {
////                rook = board.getPiece(row: newPosition.0, col: newPosition.1 + 1)!
////                board[newPosition.0, 0] = rook
////                board[newPosition.0, newPosition.1 + 1] = nil
////                rook.position = (newPosition.0, 0)
////            }
////            board[oldPosition.0, oldPosition.1] = piece
////            board[newPosition.0, newPosition.1] = nil
////            piece.position = (oldPosition.0, oldPosition.1)
////            rook.pieceMoved = false
////            piece.pieceMoved = false
////        }
////        else if isPromotion {
////            board[newPosition.0, newPosition.1] = capturedPiece
////            board[oldPosition.0, oldPosition.1] = originalPawn
////            if let pawn = originalPawn {
////                pawn.position = (oldPosition.0, oldPosition.1)
////            }
////            if let captured = capturedPiece {
////                captured.position = (newPosition.0, newPosition.1)
////            }
////        } else if isEnPassant {
////            // Correctly restoring the captured pawn
////            board[oldPosition.0, oldPosition.1] = piece
////            board[newPosition.0, newPosition.1] = nil
////            piece.position = oldPosition
////            
////            let capturedRow = oldPosition.0
////            let capturedCol = newPosition.1
////            board[capturedRow, capturedCol] = capturedPiece
////            if let capturedPiece = capturedPiece {
////                capturedPiece.position = (capturedRow, capturedCol)
////            }
////        }
////        else {
////            board[newPosition.0, newPosition.1] = capturedPiece
////            board[oldPosition.0, oldPosition.1] = piece
////            
////            piece.position = (oldPosition.0, oldPosition.1)
////            if let captured = capturedPiece {
////                captured.position = (newPosition.0, newPosition.1)
////            }
////        }
////        
////        piece.legalMoves = piece.setLegalMoves(board: board)
////        piece.legalCaptures = piece.getLegalCaptures(board: board)
////        
////        if piece.pieceType == "king" {
////            if piece.color == "white" {
////                board.whiteKingPosition = oldPosition
////            }
////            else {
////                board.blackKingPosition = oldPosition
////            }
////            
////        }
////    }
////        let redo = self.undoneMoves.removeLast()
////        self.completedMoves.append(redo)
////        
////        if redo.isPromotion {
////            board.board[redo.oldPosition.0][redo.oldPosition.1] = nil
////            if let capturedPiece = redo.capturedPiece {
////                board.board[redo.newPosition.0][redo.newPosition.1] = nil
////                board.capturedPieces.capturePiece(capturedPiece: capturedPiece)
////            }
////            board.board[redo.newPosition.0][redo.newPosition.1] = redo.piece
////        } else {
////            board.movePiece(piece: redo.piece, newPosition: redo.newPosition)//, redo.piece.get_legal_captures(board))
////        }
////        if let capturedPiece = redo.capturedPiece {
////            board.capturedPieces.capturePiece(capturedPiece: capturedPiece)
////        }
//        // if redo.captured_piece is not None:
//        //     board[redo.new_pos[0]][redo.new_pos[1]] = redo.captured_piece
////    }
