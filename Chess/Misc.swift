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

let maxTimeRemaining = 600
