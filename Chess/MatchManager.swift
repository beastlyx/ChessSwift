//
//  MatchManager.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 8/1/24.
//

import Foundation
import GameKit
import PencilKit

class MatchManager: NSObject, ObservableObject {
    @Published var inGame = false
    @Published var isGameOver = false
    @Published var authenticationState = PlayerAuthState.authenticating
    
    @Published var currentlyMoving = false
    @Published var turnPrompt = ""
    @Published var pastMoves = [MoveData]()
//    @Published var remainingTime = maxTimeRemaining {
//        willSet {
//            if isTimeKeeper { sendMove("timer:\(newValue)") }
//            if newValue < 0 { gameOver() }
//        }
//    }
//    @Published var isTimeKeeper = false
    @Published var lastReceivedMove = MoveData()
    @Published var isWhite = false
    
    var match: GKMatch?
    var otherPlayer: GKPlayer?
    var localPlayer = GKLocalPlayer.local
    
    var playerUUIDKey = UUID().uuidString
        
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
                print(error.localizedDescription)
                return
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
    
//    func startGame(newMatch: GKMatch) {
//        match = newMatch
//        match?.delegate = self
//        otherPlayer = match?.players.first
//        turnPrompt = "White to move"
//        
//        sendMove("began:\(playerUUIDKey)")
//    }
//    func startGame(newMatch: GKMatch) {
//        inGame = true
//        match = newMatch
//        match?.delegate = self
//        otherPlayer = match?.players.first
//        
//        // Determine who moves first based on UUID comparison
//        let playerIsFirst = playerUUIDKey < (otherPlayer?.gamePlayerID ?? "")
//        currentlyMoving = playerIsFirst
//        turnPrompt = playerIsFirst ? "Your move - You are playing white" : "Opponent's move - You are playing black"
////        timeKeeper = playerIsFirst
//    }
    func startGame(newMatch: GKMatch) {
        inGame = true
        match = newMatch
        match?.delegate = self
        otherPlayer = match?.players.first
        
        determineRoles()
    }
    
    func determineRoles() {
        guard let otherPlayer = otherPlayer else { return }
        
        if playerUUIDKey < otherPlayer.gamePlayerID {
            isWhite = true
            currentlyMoving = true
            turnPrompt = "Your move - You are playing white"
        } else {
            isWhite = false
            currentlyMoving = false
            turnPrompt = "Opponent's move - You are playing black"
        }
    }
    
    func swapRoles() {
        currentlyMoving = !currentlyMoving
        turnPrompt = turnPrompt == "White to move" ? "Black to move" : "White to move"
    }
    
    func gameOver() {
        isGameOver = true
        match?.disconnect()
    }
    
    func resetGame() {
        DispatchQueue.main.async { [self] in
            isGameOver = false
            inGame = false
            turnPrompt = ""
//            remainingTime = maxTimeRemaining
            lastReceivedMove = MoveData()
        }
//        isTimeKeeper = false
        match?.delegate = nil
        match = nil
        otherPlayer = nil
        pastMoves.removeAll()
        playerUUIDKey = UUID().uuidString
    }
    
//    func sendMove(_ move: MoveData) {
//        guard let data = try? JSONEncoder().encode(move) else { return }
//        try? match?.sendData(toAllPlayers: data, with: .reliable)
//    }
//    
//    func receiveMove(data: Data) {
//        if let move = try? JSONDecoder().decode(MoveData.self, from: data) {
//            DispatchQueue.main.async {
//                self.lastReceivedMove = move
//                self.pastMoves.append(move)
//                self.swapRoles()
//            }
//        }
//    }
}
