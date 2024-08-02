import Foundation
import Network

class ChessServer: ObservableObject {
    private var listener: NWListener?
    @Published var connections: [UUID: NWConnection] = [:]
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
        connections.forEach { $1.cancel() }
        connections.removeAll()
        listener = nil
        isListening = false
        statusMessages.append("Server stopped listening")
    }

    private func setupConnection(_ connection: NWConnection) {
        let connectionID = UUID()
        connections[connectionID] = connection
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.receive(from: connection, id: connectionID)
            case .failed(let error):
                self?.statusMessages.append("Client connection failed: \(error.localizedDescription)")
                self?.removeConnection(id: connectionID)
            default:
                break
            }
        }
        connection.start(queue: .main)
    }

    private func receive(from connection: NWConnection, id: UUID) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { [weak self] data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                self?.currentTurn.toggle()
                let turn = self?.currentTurn == true ? "white" : "black"
                self?.statusMessages.append("Current turn: \(turn)")
                self?.handleReceivedData(data, excluding: connection)
            }
            if isComplete {
                self?.removeConnection(id: id)
            } else if error == nil {
                self?.receive(from: connection, id: id)
            }
        }
    }

    private func handleReceivedData(_ data: Data, excluding: NWConnection) {
        for (id, connection) in connections where connection !== excluding {
            send(data: data, to: connection)
        }
    }

    private func send(data: Data, to connection: NWConnection) {
        connection.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                self.statusMessages.append("Failed to send data: \(error.localizedDescription)")
            }
        }))
    }

    private func removeConnection(id: UUID) {
        connections[id]?.cancel()
        connections.removeValue(forKey: id)
    }
}
