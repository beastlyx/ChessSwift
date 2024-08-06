//
//  Misc.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 8/1/24.
//

import Foundation

enum PlayerAuthState: String {
    case authenticating = "Logging into Game Center..."
    case unauthenticated = "Please sign in to Game Center to play."
    case authenticated = ""
    
    case error = "There was an error logging into Game Center."
    case restricted = "You're not allowed to play multiplayer games!"
}

struct MoveData: Identifiable, Codable, Equatable {
    let id: UUID
    var originalPosition: Position
    var newPosition: Position
    var isPromotion: Bool
    var pieceType: String

    init(originalPosition: Position = Position(x: -1, y: -1), newPosition: Position = Position(x: -1, y: -1), isPromotion: Bool = false, pieceType: String = "") {
        self.id = UUID()
        self.originalPosition = originalPosition
        self.newPosition = newPosition
        self.isPromotion = isPromotion
        self.pieceType = pieceType
    }
    
    static func == (lhs: MoveData, rhs: MoveData) -> Bool {
        lhs.id == rhs.id &&
        lhs.originalPosition == rhs.originalPosition &&
        lhs.newPosition == rhs.newPosition &&
        lhs.isPromotion == rhs.isPromotion &&
        lhs.pieceType == rhs.pieceType
    }
}

struct Position: Hashable, Codable {
    var x: Int
    var y: Int
    
    func destructure() -> (Int, Int) {
        return (x, y)
    }
}

let maxTimeRemaining = 600
