//
//  MatchManager.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 8/1/24.
//

import Foundation
import GameKit


class MatchManager: NSObject, ObservableObject {
    @Published var inGame = false
    @Published var isGameOver = false
    @Published var authenticationState = PlayerAuthState.authenticating
    
    @Published var currentTurn = false
    @Published var remainingTime = maxTimeRemaining
    @Published var isTimeKeeper = false
    @Published var lastReceivedMove = MoveData(oldRow: 0, oldCol: 0, newRow: 0, newCol: 0, isPromotion: false, pieceType: "")
    
    
    var match: GKMatch?
    var otherPlayer: GKPlayer?
    var localPlayer = GKLocalPlayer.local
    
    var playerUUIDKey = UUID().uuidString
    
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    
    func authentizateUser() {
        GKLocalPlayer.local.authenticateHandler = { [self] vc, e in
            if let viewController = vc {
                rootViewController?.present(viewController, animated: true)
                return
            }
            if let error = e {
                authenticationState = .error
                print(error.localizedDescription)
            }
            
            if localPlayer.isAuthenticated {
                if localPlayer.isMultiplayerGamingRestricted {
                    authenticationState = .restricted
                } else {
                    authenticationState = .authenticated
                }
            }
            else {
                authenticationState = .unauthenticated
            }
            
        }
        
        
    }
    
    func startMatchmaking() {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        
        let matchmakingVC = GKMatchmakerViewController(matchRequest: request)
        matchmakingVC?.matchmakerDelegate = self
        
        rootViewController?.present(matchmakingVC!, animated: true)
    }
    
    func startGame(newMatch: GKMatch) {
        match = newMatch
        match?.delegate = self
        otherPlayer = match?.players.first
        
        sendString("began:\(playerUUIDKey)")
    }
    
    func receivedString(_ message: String) {
        let messageSplit = message.split(separator: ":")
        guard let messagePrefix = messageSplit.first else { return }
        
        let parameter = String(messageSplit.last ?? "")
        
        switch messagePrefix {
        case "began":
            if playerUUIDKey == parameter {
                playerUUIDKey = UUID().uuidString
                sendString("began:\(playerUUIDKey)")
            }
            
            currentTurn = playerUUIDKey < parameter
            inGame = true
            
            if isTimeKeeper {
                countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            }
        default:
            break
        }
    }
}
