
import SwiftUI

struct CapturedPiecesView: View {
    var capturedPieces: [String: [GamePiece]]
    var body: some View {
        HStack(spacing: -10) {
            let order = ["queen", "rook", "bishop", "knight", "pawn"]

            ForEach(order, id: \.self) { pieceType in
                if let pieces = capturedPieces[pieceType], !pieces.isEmpty {
                    ForEach(pieces.indices, id: \.self) { index in
                        if let img = pieces[index].img {
                            Image(uiImage: img)
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                    }
                }
            }
        }
    }
}
