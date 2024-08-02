import SwiftUI

struct ChessBorderView: View {
    var squareSize: CGFloat
    var color1: Color
    var color2: Color
    var flipped: Bool
    var columnCoordinates = ["a", "b", "c", "d", "e", "f", "g", "h"]
    var rowCoordinates = ["1", "2", "3", "4", "5", "6", "7", "8"]
    
    var body: some View {
        let borderSize = squareSize * 8
        let boardSize = borderSize * 0.95
        ZStack {
            Rectangle()
                .fill(Color(red: 65/255, green: 65/255, blue: 65/255))
                .frame(width: borderSize, height: borderSize)
            ForEach(0..<8, id: \.self) { row in
                ForEach(0..<8, id: \.self) { col in
                    let displayRow = flipped ? 7 - row : row
                    let displayCol = flipped ? 7 - col : col
                    if displayRow == 0 {
                        Text(columnCoordinates[displayCol])
                            .foregroundColor(Color.white)
                            .position(x: CGFloat(col) * (boardSize / 8) + (boardSize / 11), y: squareSize * 0.1)
                            .font(.system(size: 10).bold())
                    }
                    if displayRow == 7 {
                        Text(columnCoordinates[displayCol])
                            .foregroundColor(Color.white)
                            .position(x: CGFloat(col) * (boardSize / 8) + (boardSize / 11), y: borderSize - squareSize * 0.1)
                            .font(.system(size: 10).bold())
                    }
                    if displayCol == 0 {
                        Text(rowCoordinates[7 - displayRow])
                            .foregroundColor(Color.white)
                            .position(x: squareSize * 0.1, y: CGFloat(row) * (boardSize / 8) + (boardSize / 11))
                            .font(.system(size: 10).bold())
                    }
                    if displayCol == 7 {
                        Text(rowCoordinates[7 - displayRow])
                            .foregroundColor(Color.white)
                            .position(x: borderSize - squareSize * 0.1, y: CGFloat(row) * (boardSize / 8) + (boardSize / 11))
                            .font(.system(size: 10).bold())
                    }
                }
            }
            ChessBoardView(squareSize: boardSize / 8, color1: color1, color2: color2, flipped: flipped)
                .frame(width: boardSize, height: boardSize)
        }
        .frame(width: boardSize, height: boardSize)
        .position(x: borderSize / 2, y: borderSize / 2)
    }
}

struct ChessBoardView: View {
    var squareSize: CGFloat
    var color1: Color
    var color2: Color
    var flipped: Bool
    var columnCoordinates = ["a", "b", "c", "d", "e", "f", "g", "h"]
    var rowCoordinates = ["1", "2", "3", "4", "5", "6", "7", "8"]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { col in
                        let displayRow = flipped ? 7 - row : row
                        let displayCol = flipped ? 7 - col : col
                        ZStack {
                            Rectangle()
                                .fill((displayRow + displayCol) % 2 == 0 ? color1 : color2)
                                .frame(width: squareSize, height: squareSize)
                        }
                    }
                }
            }
        }
    }
}
