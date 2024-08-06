//
//  MoveLogView.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 7/31/24.
//

import SwiftUI

struct MoveLogView: View {
    @ObservedObject var board: Board
    @Binding var selectedMoveIndex: Int?
    @Binding var whiteMove: Bool
    @Binding var isMate: Bool
    
    var body: some View {
        let moves = board.getMoveLog()
        ScrollView {
            Spacer().frame(width: 1, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                ForEach(0..<((moves.count / 2) + 1), id: \.self) { index in
                    HStack(spacing: 0) {
                        Text("\(index + 1).")
                            .frame(width: 25, alignment: .leading)
                            .font(.system(size: 14))
                            .foregroundColor(Color.black.opacity(0.1))  // Apply transparency to the number
                            .fixedSize(horizontal: true, vertical: false)
                        if index * 2 < moves.count {
                            let moveIndex = index * 2
                            HStack(spacing: 0) {
                                Image(uiImage: moves[moveIndex].piece.img!)
                                    .resizable()
                                    .frame(width: 17, height: 17, alignment: .trailing)
                                Text(moves[moveIndex].move)
                                    .frame(width: 60, alignment: .leading)
                                    .font(.system(size: 14))
                                    .foregroundColor(selectedMoveIndex == moveIndex ? .blue : Color.black.opacity(0.4))  // Apply transparency to the move
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            .onTapGesture {
                                selectedMoveIndex = moveIndex
                                setMove(index: moveIndex)
                            }
                        }
                        if index * 2 + 1 < moves.count {
                            let moveIndex = index * 2 + 1
                            HStack(spacing: 0) {
                                Spacer().frame(width: 30)
                            Image(uiImage: moves[moveIndex].piece.img!)
                                .resizable()
                                .frame(width: 17, height: 17, alignment: .leading)
                            Text(moves[moveIndex].move)
                                .frame(width: 60, alignment: .leading)
                                .font(.system(size: 14))
                                .foregroundColor(selectedMoveIndex == moveIndex ? .blue : Color.black.opacity(0.4))  // Apply transparency to the move
                                .fixedSize(horizontal: true, vertical: false)
                            }
                            .onTapGesture {
                                selectedMoveIndex = moveIndex
                                setMove(index: moveIndex)
                            }
                        }
                    }
                    Divider()
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)  // Align to top
            .padding(.horizontal, 10)
        }
    }
    
    private func setMove(index: Int) {
        board.setMove(index: index)
        whiteMove = board.whiteTurn
        isMate = board.getMoveLog().last?.isCheckmate == true ? true : false
    }
}
