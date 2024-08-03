//
//  MatchManager+GKMatchDelegate.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 8/2/24.
//

import Foundation
import GameKit

extension MatchManager: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
//        let content = String(decoding: data, as: UTF8.self)
//        
//        if content.starts(with: "strData:") {
//            let message = content.replacing("strData:", with: "")
//            receivedString(message)
//        } else {
//            do {
//                lastReceivedMove = MoveData(oldRow: 0, oldCol: 0, newRow: 0, newCol: 0, isPromotion: false, pieceType: "")
//            }
//        }
        do {
            let moveData = try JSONDecoder().decode(MoveData.self, from: data)
            DispatchQueue.main.async {
                self.receivedMove(moveData)
            }
        } catch {
            print("oops! found an error:\(error)")
        }
    }
    
    func sendString(_ message: String) {
        guard let encoded = "strData:\(message)".data(using: .utf8) else { return }
        sendData(encoded, mode: .reliable)
    }
    
    func sendData(_ data: Data, mode: GKMatch.SendDataMode) {
        do {
            try match?.sendData(toAllPlayers: data, with: mode)
        } catch {
            print(error)
        }
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        guard state == .disconnected && !isGameOver else { return }
        let alert = UIAlertController(title: "Player Disconnected", message: "The other player disconnected from the game.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            self.match?.disconnect()
        })
        DispatchQueue.main.async {
            self.resetGame()
            self.rootViewController?.present(alert, animated: true)
        }
        print("Player \(player.displayName) did change state: \(state.rawValue)") // Debugging
    }
}
