//
//import Foundation
//
//class CapturedPieces {
//    var whitePieces: [String: [GamePiece]] = [:]
//    var blackPieces: [String: [GamePiece]] = [:]
//
//    init() {
//        self.whitePieces["queen"] = []
//        self.whitePieces["rook"] = []
//        self.whitePieces["bishop"] = []
//        self.whitePieces["knight"] = []
//        self.whitePieces["pawn"] = []
//        
//        self.blackPieces["queen"] = []
//        self.blackPieces["rook"] = []
//        self.blackPieces["bishop"] = []
//        self.blackPieces["knight"] = []
//        self.blackPieces["pawn"] = []
//    }
//    
//    func reset() {
//        self.whitePieces = [:]
//        self.whitePieces["queen"] = []
//        self.whitePieces["rook"] = []
//        self.whitePieces["bishop"] = []
//        self.whitePieces["knight"] = []
//        self.whitePieces["pawn"] = []
//        
//        self.blackPieces = [:]
//        self.blackPieces["queen"] = []
//        self.blackPieces["rook"] = []
//        self.blackPieces["bishop"] = []
//        self.blackPieces["knight"] = []
//        self.blackPieces["pawn"] = []
//    }
//    
//    func deepCopy() -> CapturedPieces {
//        let copy = CapturedPieces()
//        for (key, pieces) in self.whitePieces {
//            copy.whitePieces[key] = pieces.map { $0.copy() }
//        }
//        for (key, pieces) in self.blackPieces {
//            copy.blackPieces[key] = pieces.map { $0.copy() }
//        }
//        return copy
//    }
//    
//    func calculateWhitePoints() -> Int {
//        var whitePoints = 0
//        self.whitePieces.values.forEach { piecesArray in
//            piecesArray.forEach { piece in
//                whitePoints += piece.points
//            }
//        }
//        return whitePoints
//    }
//
//    func calculateBlackPoints() -> Int {
//        var blackPoints = 0
//        self.blackPieces.values.forEach { piecesArray in
//            piecesArray.forEach { piece in
//                blackPoints += piece.points
//            }
//        }
//        return blackPoints
//    }
//
//    func capturePiece(capturedPiece: GamePiece) {
//        let color = capturedPiece.color
//        let type = capturedPiece.pieceType
//        if color == "black" {
//            self.blackPieces[type]?.append(capturedPiece)
//        } else {
//            self.whitePieces[type]?.append(capturedPiece)
//        }
//    }
//
//    func undoCapturedPiece(capturedPiece: GamePiece) {
//        let color = capturedPiece.color
//        let type = capturedPiece.pieceType
//        
//        if color == "black" {
//            if let pieces = self.blackPieces[type], !pieces.isEmpty {
//                self.blackPieces[type]?.removeLast()
//            }
//        } else {
//            if let pieces = self.whitePieces[type], !pieces.isEmpty {
//                self.whitePieces[type]?.removeLast()
//            }
//        }
//    }
//    
//    func getWhiteCapturedPieces() -> [String: [GamePiece]] {
//        return self.whitePieces
//    }
//    
//    func getBlackCapturedPieces() -> [String: [GamePiece]] {
//        return self.blackPieces
//    }
//}
