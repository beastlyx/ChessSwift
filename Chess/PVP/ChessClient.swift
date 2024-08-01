import Foundation
import Network

class ChessClient {
    private var connection: NWConnection?
    private var gameState: Board
    
    init() {
        self.gameState = Board()
    }
    
    func connectToServer() {
        connection = NWConnection(host: "localhost", port: 8888, using: .tcp)
        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("Connected to server")
                self.receive()
            case .failed(let error):
                print("Connection failed: \(error)")
            default:
                break
            }
        }
        connection?.start(queue: .main)
    }
    
    private func receive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                self.handleReceivedData(data)
            }
            if isComplete {
                print("Connection closed")
            } else if error == nil {
                self.receive()
            }
        }
    }
    
    private func handleReceivedData(_ data: Data) {
        do {
            let moveData = try JSONDecoder().decode(MoveData.self, from: data)
            DispatchQueue.main.async {
                // Assuming you have a method to convert MoveData back to MoveLog
                let moveLog = self.convertMoveDataToMoveLog(moveData)
                self.gameState.applyMove(moveLog)
                // Optionally: update UI here
            }
        } catch {
            print("Error decoding received data: \(error)")
        }
    }

    // Helper method to convert MoveData to MoveLog
    private func convertMoveDataToMoveLog(_ moveData: MoveData) -> MoveLog {
        // You'll need to adjust this according to how MoveLog is structured and initialized
        return MoveLog(
            board: gameState,
            piece: nil,
            oldPosition: (moveData.oldPosition.row, moveData.oldPosition.column),
            newPosition: (moveData.newPosition.row, moveData.newPosition.column),
            isPromotion: moveData.isPromotion,
            isCastle: moveData.isCastle,
            isEnPassant: moveData.isEnPassant,
            originalPawn: nil // Adjust based on your actual MoveLog initializers
        )
    }
    
    func sendMove(moveLog: MoveLog) {
        let moveData = MoveData(from: moveLog)
        do {
            let data = try JSONEncoder().encode(moveData)
            connection?.send(content: data, completion: .contentProcessed({ error in
                if let error = error {
                    print("Failed to send move data: \(error)")
                }
            }))
        } catch {
            print("Error encoding move data: \(error)")
        }
    }
}
struct MoveData: Codable {
    var oldPosition: Position
    var newPosition: Position
    var isPromotion: Bool
    var isCastle: Bool
    var isEnPassant: Bool
    var promotionPiece: String?
    
    init(from moveLog: MoveLog) {
        self.oldPosition = Position(row: moveLog.oldPosition.0, column: moveLog.oldPosition.1)
        self.newPosition = Position(row: moveLog.newPosition.0, column: moveLog.newPosition.1)
        self.isPromotion = moveLog.isPromotion
        self.isCastle = moveLog.isCastle
        self.isEnPassant = moveLog.isEnPassant
        
        if moveLog.isPromotion == true {
            self.promotionPiece = moveLog.piece.pieceType
        } else {
            self.promotionPiece = ""
        }
    }
}

struct Position: Codable {
    var row: Int
    var column: Int
}
