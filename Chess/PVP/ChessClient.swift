////import Foundation
////import Network
////
////class ChessClient: ObservableObject {
////    private var connection: NWConnection?
////    @Published var isConnected = false
////    @Published var board = Board()
////    @Published var flipped = false
////    @Published var isWhite = false
////    @Published var isClientTurn: Bool
////    @Published var waitingForOpponent: Bool
////    
////    let uuidString = UUID().uuidString
////
////    init() {
////        self.flipped = false
////        self.isWhite = false
////        self.isClientTurn = false
////        self.waitingForOpponent = true
////    }
//////    init(flipped: Bool, isWhite: Bool) {
//////        self.flipped = flipped
//////        self.isWhite = isWhite
//////        self.isClientTurn = isWhite
//////    }
////
////    func connectToServer() {
////        connection = NWConnection(host: "localhost", port: 8888, using: .tcp)
////        connection?.stateUpdateHandler = { [weak self] state in
////            switch state {
////            case .ready:
////                DispatchQueue.main.async {
////                    self?.isConnected = true
////                }
////                self?.sendUUID()
////                self?.receive()
////            case .failed(let error):
////                print("Client connection failed: \(error)")
////                DispatchQueue.main.async {
////                    self?.isConnected = false
////                }
////            default:
////                break
////            }
////        }
////        connection?.start(queue: .main)
////    }
////
////    private func sendUUID() {
////        guard let connection = connection else { return }
////        let data = uuidString.data(using: .utf8)
////        connection.send(content: data, completion: .contentProcessed({ error in
////            if let error = error {
////                print("Failed to send UUID: \(error)")
////            }
////        }))
////    }
////
////    private func receive() {
////        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024) { [weak self] data, _, isComplete, error in
////            if let data = data, !data.isEmpty {
////                self?.handleReceivedData(data)
////            }
////            if isComplete {
////                DispatchQueue.main.async {
////                    self?.isConnected = false
////                }
////            } else if error == nil {
////                self?.receive()
////            }
////        }
////    }
////
////    private func handleReceivedData(_ data: Data) {
////        do {
////            let moveData = try JSONDecoder().decode(MoveData.self, from: data)
////            DispatchQueue.main.async {
////                self.board.applyMove(from: (moveData.oldRow, moveData.oldCol), to: (moveData.newRow, moveData.newCol), isPromotion: moveData.isPromotion, pieceType: moveData.pieceType)
////            }
////        } catch {
////            print("Error decoding received data: \(error)")
////        }
////    }
////
////    func sendMove(oldRow: Int, oldCol: Int, newRow: Int, newCol: Int, isPromotion: Bool, pieceType: String) {
////        let moveData = MoveData(oldRow: oldRow, oldCol: oldCol, newRow: newRow, newCol: newCol, isPromotion: isPromotion, pieceType: pieceType)
////        do {
////            let data = try JSONEncoder().encode(moveData)
////            connection?.send(content: data, completion: .contentProcessed({ error in
////                if let error = error {
////                    print("Failed to send move data: \(error)")
////                }
////            }))
////        } catch {
////            print("Error encoding move data: \(error)")
////        }
////    }
////}
//import Foundation
//import Network
//
//class ChessClient: ObservableObject {
//    private var connection: NWConnection?
//    @Published var isConnected = false
//    @Published var board = Board()
//    @Published var flipped = false
//    @Published var isWhite = false
//    @Published var isClientTurn = false
//    
//    let uuidString = UUID().uuidString
//
//    init() {
//        self.flipped = false
//        self.isWhite = false
//        self.isClientTurn = false
//    }
//
//    func connectToServer() {
//        connection = NWConnection(host: "localhost", port: 8888, using: .tcp)
//        connection?.stateUpdateHandler = { [weak self] state in
//            switch state {
//            case .ready:
//                self?.sendUUID()
//                self?.receive()
//            case .failed(let error):
//                print("Client connection failed: \(error)")
//                DispatchQueue.main.async {
//                    self?.isConnected = false
//                }
//            default:
//                break
//            }
//        }
//        connection?.start(queue: .main)
//    }
//
//    private func sendUUID() {
//        guard let connection = connection else { return }
//        let data = uuidString.data(using: .utf8)
//        connection.send(content: data, completion: .contentProcessed({ error in
//            if let error = error {
//                print("Failed to send UUID: \(error)")
//            }
//        }))
//    }
//
//    private func receive() {
//        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024) { [weak self] data, _, isComplete, error in
//            if let data = data, !data.isEmpty {
//                self?.handleReceivedData(data)
//            }
//            if isComplete {
//                DispatchQueue.main.async {
//                    self?.isConnected = false
//                }
//            } else if error == nil {
//                self?.receive()
//            }
//        }
//    }
//
//    private func handleReceivedData(_ data: Data) {
//        if data.count == 1, let role = data.first {
//            DispatchQueue.main.async {
//                self.isWhite = (role == 1)
//                self.flipped = !self.isWhite
//                self.isClientTurn = self.isWhite
//                self.isConnected = true
//            }
//        } else {
//            do {
//                let moveData = try JSONDecoder().decode(MoveData.self, from: data)
//                DispatchQueue.main.async {
//                    self.board.applyMove(from: (moveData.oldRow, moveData.oldCol), to: (moveData.newRow, moveData.newCol), isPromotion: moveData.isPromotion, pieceType: moveData.pieceType)
//                }
//            } catch {
//                print("Error decoding received data: \(error)")
//            }
//        }
//    }
//
//    func sendMove(oldRow: Int, oldCol: Int, newRow: Int, newCol: Int, isPromotion: Bool, pieceType: String) {
//        let moveData = MoveData(oldRow: oldRow, oldCol: oldCol, newRow: newRow, newCol: newCol, isPromotion: isPromotion, pieceType: pieceType)
//        do {
//            let data = try JSONEncoder().encode(moveData)
//            connection?.send(content: data, completion: .contentProcessed({ error in
//                if let error = error {
//                    print("Failed to send move data: \(error)")
//                }
//            }))
//        } catch {
//            print("Error encoding move data: \(error)")
//        }
//    }
//}
import Foundation
import Network

class ChessClient: ObservableObject {
    private var connection: NWConnection?
    @Published var isConnected = false
    @Published var board = Board()
    @Published var flipped = false
    @Published var isWhite = false
    @Published var isClientTurn = false

    let uuidString = UUID().uuidString

    init() {
        self.flipped = false
        self.isWhite = false
        self.isClientTurn = false
    }

    func connectToServer() {
        connection = NWConnection(host: "localhost", port: 8888, using: .tcp)
        connection?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.sendUUID()
                self?.receive()
            case .failed(let error):
                print("Client connection failed: \(error)")
                DispatchQueue.main.async {
                    self?.isConnected = false
                }
            default:
                break
            }
        }
        connection?.start(queue: .main)
    }

    private func sendUUID() {
        guard let connection = connection else { return }
        let data = uuidString.data(using: .utf8)
        connection.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print("Failed to send UUID: \(error)")
            }
        }))
    }

    private func receive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024) { [weak self] data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                self?.handleReceivedData(data)
            }
            if isComplete {
                DispatchQueue.main.async {
                    self?.isConnected = false
                }
            } else if error == nil {
                self?.receive()
            }
        }
    }

    private func handleReceivedData(_ data: Data) {
        if data.count == 1, let role = data.first {
            DispatchQueue.main.async {
                self.isWhite = (role == 1)
                self.flipped = !self.isWhite
                self.isClientTurn = self.isWhite
                self.isConnected = true
            }
        } else {
            do {
                let moveData = try JSONDecoder().decode(MoveData.self, from: data)
                DispatchQueue.main.async {
                    self.board.applyMove(from: (moveData.oldRow, moveData.oldCol), to: (moveData.newRow, moveData.newCol), isPromotion: moveData.isPromotion, pieceType: moveData.pieceType)
                }
            } catch {
                print("Error decoding received data: \(error)")
            }
        }
    }

    func sendMove(oldRow: Int, oldCol: Int, newRow: Int, newCol: Int, isPromotion: Bool, pieceType: String) {
        let moveData = MoveData(oldRow: oldRow, oldCol: oldCol, newRow: newRow, newCol: newCol, isPromotion: isPromotion, pieceType: pieceType)
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
