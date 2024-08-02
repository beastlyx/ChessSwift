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
        let content = String(decoding: data, as: UTF8.self)
        
        if content.starts(with: "strData:") {
            let message = content.replacing("strData:", with: "")
            receivedString(message)
        } else {
            do {
                lastReceivedMove = MoveData(oldRow: 0, oldCol: 0, newRow: 0, newCol: 0, isPromotion: false, pieceType: "")
            }
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
        <#code#>
    }
}
