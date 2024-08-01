import Foundation
import Network

class ChessServer {
    private var listener: NWListener?
    private var connections: [NWConnection] = []
    private var gameState: Board

    init() {
        self.gameState = Board()
        startListening()
    }

    func startListening() {
        do {
            listener = try NWListener(using: .tcp, on: 8888)
            listener?.newConnectionHandler = { [weak self] connection in
                self?.setupConnection(connection)
            }
            listener?.start(queue: .main)
        } catch {
            print("Failed to start listener: \(error)")
        }
    }

    private func setupConnection(_ connection: NWConnection) {
        connections.append(connection)
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("Client connected")
                self.receive(from: connection)
            case .failed(let error):
                print("Client connection failed: \(error)")
                self.removeConnection(connection)
            default:
                break
            }
        }
        connection.start(queue: .main)
    }

    private func receive(from connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                self.handleReceivedData(data, from: connection)
            }
            if isComplete {
                self.removeConnection(connection)
            } else if error == nil {
                self.receive(from: connection)
            }
        }
    }

    func handleReceivedData(_ data: Data, from connection: NWConnection) {
        do {
            // Decode the received JSON data into MoveData
            let moveData = try JSONDecoder().decode(MoveData.self, from: data)

            // Apply the move data directly to the game state, assuming you have such functionality
            // This part depends on your `Board` class having a method to handle `MoveData`
            if gameState.applyMoveData(moveData) {
                // If move is valid, broadcast it to all clients
                broadcastMove(moveData)
            } else {
                // If the move is not valid, send an error back to the sender
                sendError("Invalid move", to: connection)
            }
        } catch {
            print("Error decoding move data: \(error)")
            // Optionally send an error feedback to the connection
            sendError("Error processing move data", to: connection)
        }
    }

    private func broadcastMove(_ moveData: MoveData) {
        guard let data = try? JSONEncoder().encode(moveData) else { return }
        for conn in connections {
            send(data: data, to: conn)
        }
    }

    private func sendError(_ message: String, to connection: NWConnection) {
        guard let data = message.data(using: .utf8) else { return }
        send(data: data, to: connection)
    }

    private func send(data: Data, to connection: NWConnection) {
        connection.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print("Failed to send data: \(error)")
            }
        }))
    }

    private func removeConnection(_ connection: NWConnection) {
        if let index = connections.firstIndex(of: connection) {
            connections.remove(at: index)
        }
    }
}
