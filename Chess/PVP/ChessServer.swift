import Foundation
import Network

//class ChessServer: ObservableObject {
//    private var listener: NWListener?
////    @Published var connections: [UUID: NWConnection] = [:]
//    private var player1: NWConnection?
//    private var player2: NWConnection?
//    @Published var isListening = false
//    @Published var statusMessages: [String] = []
//    @Published var currentTurn: Bool = true
//    
//    func startListening() {
//        do {
//            listener = try NWListener(using: .tcp, on: 8888)
//            listener?.newConnectionHandler = { [weak self] connection in
//                self?.setupConnection(connection)
//            }
//            listener?.start(queue: .main)
//            isListening = true
//            statusMessages.append("Server started listening")
//        } catch {
//            statusMessages.append("Failed to start listener: \(error.localizedDescription)")
//        }
//    }
//
//    func stopListening() {
//        listener?.cancel()
//        listener = nil
//        player1?.cancel()
//        player2?.cancel()
//        player1 = nil
//        player2 = nil
//        isListening = false
//        statusMessages.append("Server stopped listening")
//    }
//
//    private func setupConnection(_ connection: NWConnection) {
//        let connectionID = UUID()
//        connections[connectionID] = connection
//        connection.stateUpdateHandler = { [weak self] state in
//            switch state {
//            case .ready:
//                self?.receive(from: connection, id: connectionID)
//            case .failed(let error):
//                self?.statusMessages.append("Client connection failed: \(error.localizedDescription)")
//                self?.removeConnection(id: connectionID)
//            default:
//                break
//            }
//        }
//        connection.start(queue: .main)
//    }
//
//    private func receive(from connection: NWConnection, id: UUID) {
//        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { [weak self] data, _, isComplete, error in
//            if let data = data, !data.isEmpty {
//                self?.currentTurn.toggle()
//                let turn = self?.currentTurn == true ? "white" : "black"
//                self?.statusMessages.append("Current turn: \(turn)")
//                self?.handleReceivedData(data, excluding: connection)
//            }
//            if isComplete {
//                self?.removeConnection(id: id)
//            } else if error == nil {
//                self?.receive(from: connection, id: id)
//            }
//        }
//    }
//
//    private func handleReceivedData(_ data: Data, excluding: NWConnection) {
//        for (id, connection) in connections where connection !== excluding {
//            send(data: data, to: connection)
//        }
//    }
//
//    private func send(data: Data, to connection: NWConnection) {
//        connection.send(content: data, completion: .contentProcessed({ error in
//            if let error = error {
//                self.statusMessages.append("Failed to send data: \(error.localizedDescription)")
//            }
//        }))
//    }
//
//    private func removeConnection(id: UUID) {
//        connections[id]?.cancel()
//        connections.removeValue(forKey: id)
//    }
//}
class ChessServer: ObservableObject {
    private var listener: NWListener?
    private var player1: NWConnection?
    private var player2: NWConnection?
    @Published var isListening = false
    @Published var statusMessages: [String] = []
    @Published var currentTurn: Bool = true

    func startListening() {
        do {
            listener = try NWListener(using: .tcp, on: 8888)
            listener?.newConnectionHandler = { [weak self] connection in
                self?.setupConnection(connection)
            }
            listener?.start(queue: .main)
            isListening = true
            statusMessages.append("Server started listening")
        } catch {
            statusMessages.append("Failed to start listener: \(error.localizedDescription)")
        }
    }

    func stopListening() {
        listener?.cancel()
        listener = nil
        player1?.cancel()
        player2?.cancel()
        player1 = nil
        player2 = nil
        isListening = false
        statusMessages.append("Server stopped listening")
    }

    private func setupConnection(_ connection: NWConnection) {
        if player1 == nil {
            player1 = connection
            receive(from: connection, player: 1)
            statusMessages.append("Player 1 connected")
        } else if player2 == nil {
            player2 = connection
            receive(from: connection, player: 2)
            statusMessages.append("Player 2 connected")
            assignRoles() // Assign roles only when both players are connected
        } else {
            connection.cancel()
            statusMessages.append("Rejected connection: server already has two players")
        }
    }

    private func assignRoles() {
        guard let player1 = player1, let player2 = player2 else { return }
        
        // Assign roles (1 for white, 0 for black)
        let player1Role: UInt8 = 1
        let player2Role: UInt8 = 0

        sendRole(player1Role, to: player1)
        sendRole(player2Role, to: player2)

        statusMessages.append("Assigned roles to both clients")
    }

    private func sendRole(_ role: UInt8, to connection: NWConnection) {
        let data = Data([role])
        send(data: data, to: connection)
    }

    private func receive(from connection: NWConnection, player: Int) {
        connection.start(queue: .main)
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { [weak self] data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                self?.handleReceivedData(data, from: connection)
            }
            if isComplete {
                connection.cancel()
            } else if error == nil {
                self?.receive(from: connection, player: player)
            }
        }
    }

    private func handleReceivedData(_ data: Data, from connection: NWConnection) {
        // Toggle current turn
        currentTurn.toggle()
        let turn = currentTurn ? "white" : "black"
        statusMessages.append("Current turn: \(turn)")

        // Forward data to the other player
        let targetConnection = (connection === player1) ? player2 : player1
        targetConnection?.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                self.statusMessages.append("Failed to forward move: \(error.localizedDescription)")
            }
        }))
    }

    private func send(data: Data, to connection: NWConnection) {
        connection.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                self.statusMessages.append("Failed to send data: \(error.localizedDescription)")
            }
        }))
    }
}
