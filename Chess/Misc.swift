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

struct MoveData: Identifiable, Equatable {
    let id = UUID()
    var originalPosition: (Int, Int)
    var newPosition: (Int, Int)
    var isPromotion: Bool
    var pieceType: String
    
    init() {
        originalPosition = (-1, -1)
        newPosition = (-1, -1)
        isPromotion = false
        pieceType = ""
    }
    
    static func ==(lhs: MoveData, rhs: MoveData) -> Bool {
        return lhs.originalPosition == rhs.originalPosition &&
               lhs.newPosition == rhs.newPosition &&
               lhs.isPromotion == rhs.isPromotion &&
               lhs.pieceType == rhs.pieceType
    }
}

let maxTimeRemaining = 600


//struct PastGuess: Identifiable {
//    let id = UUID()
//    var message: String
//    var correct: Bool
//}
