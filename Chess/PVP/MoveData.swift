//
//  MoveData.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 8/1/24.
//

import Foundation


struct MoveData: Codable {
    let oldRow: Int
    let oldCol: Int
    let newRow: Int
    let newCol: Int
    let isPromotion: Bool
    let pieceType: String
}
