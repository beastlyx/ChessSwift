import Foundation
import GameKit

extension MatchManager: GKMatchDelegate {
//    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
//        receiveMove(data: data)
//    }
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        if let content = try? JSONDecoder().decode(MoveData.self, from: data) {
            receiveMove(data: data)
        }
        
//        if content.starts(with: "strData:") {
//            let message = content.replacing("strData:", with: "")
//            receivedString(message)
//        } else {
//            do {
//                try lastReceivedDrawing = PKDrawing(data: data)
//            } catch {
//                print(error)
//            }
//        }
    }
    func sendMove(_ move: MoveData) {
        guard let data = try? JSONEncoder().encode(move) else { return }
        try? match?.sendData(toAllPlayers: data, with: .reliable)
    }
    
    func receiveMove(data: Data) {
        if let move = try? JSONDecoder().decode(MoveData.self, from: data) {
            DispatchQueue.main.async {
                self.lastReceivedMove = move
                self.pastMoves.append(move)
                self.swapRoles()
            }
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
    }
}
