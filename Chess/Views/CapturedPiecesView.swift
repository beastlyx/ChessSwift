
import SwiftUI

struct CapturedPiecesView: View {
    var capturedPieces: [String: Int]
    var body: some View {
        HStack(spacing: -10) {
            let order = ["q", "r", "b", "n", "p", "Q", "R", "B", "N", "P"]
            
            ForEach(order, id: \.self) { type in
                if let count = capturedPieces[type], count != 0 {
                    ForEach(0..<count, id: \.self) { _ in
                        if let img = getImage(for: type) {
                            Image(uiImage: img)
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                    }
                }
            }
        }
    }
    
    func getImage(for type: String) -> UIImage? {
        var piece = ""
        switch type.lowercased() {
        case "q":
            piece = "queen"
        case "r":
            piece = "rook"
        case "b":
            piece = "bishop"
        case "n":
            piece = "knight"
        case "p":
            piece = "pawn"
        default:
            break
        }
        
        if Character(type).isLowercase {
            return UIImage(named: "black-\(piece)")
        } else {
            return UIImage(named: "white-\(piece)")
        }
    }
}
