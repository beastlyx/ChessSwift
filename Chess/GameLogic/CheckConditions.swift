// Full working pins and check logic that removes any moves from valid moves that either put king in check, or dont protect king in check.
class CheckConditions {
    var piece: GamePiece
    var move: (Int, Int)?
    var board: Board
    var kingPosition: (Int, Int)
    
    init(board: Board, piece: GamePiece, move: (Int, Int)? = nil) {
        self.piece = piece.copy()
        self.move = move
        self.board = board.deepCopy()
        self.kingPosition = self.board.getKingPosition(color: piece.color)
    }
    
//    func validateMove() -> Bool {
//        if let move = self.move {
//            self.board.movePiece(piece: self.piece, newPosition: move, test: true)
//        }
//        if let piece = self.piece {
//            self.kingPosition = self.board.getKingPosition(color: piece.color == "white" ? "black" : "white")
//        } else {
//            self.kingPosition = (-1, -1)
//        }
//        
//        return self.kingInCheck()
//    }
    
    func validateMove() -> Bool {
        if let move = self.move {
            self.board.movePiece(piece: self.piece, newPosition: move, test: true)
        }
        self.kingPosition = self.board.getKingPosition(color: self.piece.color)
        return self.kingInCheck()
    }

    func kingInCheck() -> Bool {
        let moves = self.getOpponentMoves()
        return moves.contains(where: { $0 == self.kingPosition })
    }
    
    func getOpponentMoves() -> [(Int, Int)] {
        var moves: [(Int, Int)] = []
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = self.board.getPiece(row: row, col: col),
                   piece.pieceType != "king" && piece.color != self.piece.color {
                    moves.append(contentsOf: piece.getLegalMoves(board: self.board))
                }
            }
        }
        return moves
    }
    
    func kingInCheckCastle(kingPath: [(Int, Int)]) -> Bool {
        let moves = self.getOpponentMoves()
        for path in kingPath {
            if moves.contains(where: { $0 == path }) || moves.contains(where: { $0 == self.kingPosition }) {
                return true
            }
        }
        return false
    }
    
    func getPlayerMoves() -> [(Int, Int)] {
        var moves: [(Int, Int)] = []
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = self.board.getPiece(row: row, col: col), piece.color == self.piece.color {
                    piece.getLegalMoves(board: self.board)
                    moves.append(contentsOf: piece.validateLegalMoves(board: self.board))
                }
            }
        }
        return moves
    }
    
    func checkmate() -> String {
        if self.getPlayerMoves().isEmpty && self.kingInCheck() {
            return "checkmate"
        } else if self.getPlayerMoves().isEmpty && !self.kingInCheck() {
            return "stalemate"
        }
        return ""
    }
    
    // look into logic about what causes a draw in chess
    //
    // According to the rules of chess, a game can end in a draw under several conditions:
    //
    // Insufficient material: This happens when neither player has enough pieces to be able to checkmate the other. For example,
    // if only two kings remain, neither player can force a checkmate, so the game is a draw.
    //
    func countPieces() -> Bool {
        var white_count = 0
        var black_count = 0
        for row in 0..<8 {
            for col in 0..<8 {
                let piece = self.board.getPiece(row: row, col: col)
                if piece != nil {
                    if piece?.color == "white" {
                        white_count += 1
                    }
                    else {
                        black_count += 1
                    }
                }
            }
        }
        if black_count == white_count && black_count == 1 {
            return true
        }
        return false
    }
}
// Threefold repetition: This rule states that the game is a draw if the same position occurs three times, not necessarily consecutively,
// with the same player to move each time. The positions don't need to be repeated sequentially, and they can span multiple turns.
//
// Fifty-move rule: If during the last 50 consecutive moves by each player, no pawn has moved and there has been no capture, a player can
// claim a draw.
//
// Mutual agreement: Both players may simply agree to a draw, ending the game.
//
// Fivefold repetition or Seventy-five-move rule: Similar to threefold repetition and fifty-move rule but respectively need positions
// repeated five times or happening 75 turns without capture or pawn moves. These rules automatically end the game in a draw without requiring
// a claim by a player.
//
// Implementing all these rules into a computer program can be a challenge, especially correctly tracking the three/fivefold
// repetition and the fifty/seventy-five-move rule, but it's absolutely possible! You'll need a way to keep track of the entire game
// state after each move, including the positions of all pieces and whose turn it is, so you can detect repeated positions and moves
// without a pawn moving or a piece being captured.


// fix move log logic
