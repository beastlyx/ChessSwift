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
    
    @Published var message = "checkmate"
    @Published var currentTurn = true
    @Published var remainingTimeWhite = maxTimeRemaining
    @Published var remainingTimeBlack = maxTimeRemaining
    @Published var isTimeKeeper = false
    @Published var lastReceivedMove: MoveData?
    
    @Published var flipped = false
    
    var match: GKMatch?
    var otherPlayer: GKPlayer?
    var localPlayer = GKLocalPlayer.local
    
    var playerUUIDKey = UUID().uuidString
    
    var isPlayerOne = true
    
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    
    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = { [self] vc, error in
            if let viewController = vc {
                rootViewController?.present(viewController, animated: true)
                return
            }
            if let error = error {
                authenticationState = .error
                print("Game Center Authentication Error: \(error.localizedDescription)")
                return
            }
            
            if localPlayer.isAuthenticated {
                print("Game Center Authentication Successful")
                if localPlayer.isMultiplayerGamingRestricted {
                    authenticationState = .restricted
                    print("Multiplayer gaming is restricted.")
                } else {
                    authenticationState = .authenticated
                }
            }
            else {
                authenticationState = .unauthenticated
                print("Game Center Authentication Failed")
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
        
        inGame = true
        isGameOver = false
        
        isPlayerOne = GKLocalPlayer.local.gamePlayerID < (otherPlayer?.gamePlayerID ?? "")
        currentTurn = true
    }
    
    func sendMove(_ moveData: MoveData) {
        do {
            let data = try JSONEncoder().encode(moveData)
            try match?.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print(error)
        }
    }
    
    func receivedMove(_ moveData: MoveData) {
        DispatchQueue.main.async { // Ensure UI updates are performed on the main thread
            self.lastReceivedMove = moveData
            self.currentTurn.toggle()
        }
    }
    
    func resetGame() {
        self.inGame = false
        self.isGameOver = false
        self.message = "checkmate"
        self.currentTurn = true
        self.remainingTimeWhite = maxTimeRemaining
        self.remainingTimeBlack = maxTimeRemaining
        self.isTimeKeeper = false
        self.lastReceivedMove = nil
    }
}
