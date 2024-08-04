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
//    @Published var pastMoves = [MoveLog]()
    
//    @Published var score = 0
    @Published var remainingTime = maxTimeRemaining {
        willSet {
            if isTimeKeeper { sendMove("timer:\(newValue)") }
            if newValue < 0 { gameOver() }
        }
    }
    @Published var isTimeKeeper = false
    @Published var lastReceivedMove = MoveData()
    
    
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
    
    func startGame(newMatch: GKMatch) {
        match = newMatch
        match?.delegate = self
        otherPlayer = match?.players.first
        turnPrompt = "White to move"
        
        sendMove("began:\(playerUUIDKey)")
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
            remainingTime = maxTimeRemaining
            lastReceivedMove = MoveData()
        }
        isTimeKeeper = false
        match?.delegate = nil
        match = nil
        otherPlayer = nil
        pastMoves.removeAll()
        playerUUIDKey = UUID().uuidString
    }
    
    func receivedString(_ message: String) {
        let messageSplit = message.split(separator: ":")
        guard let messagePrefix = messageSplit.first else { return }
        
        let parameter = messageSplit.dropFirst().joined(separator: ":")
        
        switch messagePrefix {
        case "began":
            if playerUUIDKey == parameter {
                playerUUIDKey = UUID().uuidString
                sendMove("began:\(playerUUIDKey)")
                break
            }
            
            currentlyMoving = playerUUIDKey < parameter
            inGame = true
            isTimeKeeper = currentlyMoving
            
            if isTimeKeeper {
                countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            }
        case "move":
//            var guessCorrect = false
            
//            if parameter.lowercased() == drawPrompt {
//            sendMove("move:\(parameter)")
                
//                guessCorrect = true
//            } else {
//                sendString("incorrect:\(parameter)")
//            }
            
            appendPastMove(move: parameter)
            swapRoles()
//
//        case "correct":
//            swapRoles()
//            appendPastGuess(guess: parameter, correct: true)
//        case "incorrect":
//            appendPastGuess(guess: parameter, correct: false)
        case "timer":
            remainingTime = Int(parameter) ?? 0
        default:
            break
        }
    }

    func appendPastMove(move: String) {
        let messageSplit = move.split(separator: ":")
        
        var data = MoveData()
        data.originalPosition = parseTuple(String(messageSplit[0]))
        data.newPosition = parseTuple(String(messageSplit[1]))
        data.isPromotion = Bool(String(messageSplit[2])) ?? false
        data.pieceType = String(messageSplit[3])
        
        pastMoves.append(data)
        lastReceivedMove = data
    }
    
    func parseTuple(_ str: String) -> (Int, Int) {
        let cleanedString = str.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
        let parts = cleanedString.split(separator: ",")
        
        let first = Int(parts[0])!
        let second = Int(parts[1])!
        
        return (first, second)
    }
}
