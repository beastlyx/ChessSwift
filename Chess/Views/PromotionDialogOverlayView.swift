//
//  PromotionDialogView.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 7/31/24.
//

import SwiftUI

struct PromotionDialogOverlayView: View {
    let details: (Int, Int, String, (GamePiece) -> Void)
    let size: CGFloat
    var onSelect: (GamePiece) -> Void

    var body: some View {
        VStack {
            HStack {
                ForEach(["queen", "rook", "bishop", "knight"], id: \.self) { type in
                    Button(action: {
                        let newPiece = createPiece(type: type, color: details.2)
                        onSelect(newPiece)
                    }) {
                        Image(uiImage: UIImage(named: "\(details.2)-\(type)")!)
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(width: size * 0.5, height: size * 0.25)
        .position(x: size / 2, y: size / 2) // Center in the chessboard
    }
    
    private func createPiece(type: String, color: String) -> GamePiece {
        switch type {
        case "queen":
            return Queen(row: 0, col: 0, color: color)
        case "rook":
            return Rook(row: 0, col: 0, color: color, id: "\(color)-rook")
        case "bishop":
            return Bishop(row: 0, col: 0, color: color)
        case "knight":
            return Knight(row: 0, col: 0, color: color)
        default:
            return Queen(row: 0, col: 0, color: color)
        }
    }
}
