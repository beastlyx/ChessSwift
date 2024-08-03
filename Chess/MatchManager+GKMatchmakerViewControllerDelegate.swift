//
//  MatchManager+GKMatchmakerViewControllerDelegate.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 8/2/24.
//

import Foundation
import GameKit

extension MatchManager: GKMatchmakerViewControllerDelegate {
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(animated: true)
        print("Match found: \(match)")
        startGame(newMatch: match)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true)
        print("Matchmaking failed: \(error.localizedDescription)") // Debugging
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
        print("Matchmaking was cancelled")
    }
    
    
}
