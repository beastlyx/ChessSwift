import SwiftUI

struct ChessBoarderView: View {
    var squareSize: CGFloat
    var color1: Color
    var color2: Color
    var columnCoordinates = ["a", "b", "c", "d", "e", "f", "g", "h"]
    var rowCoordinates = ["1", "2", "3", "4", "5", "6", "7", "8"]
    
    var body: some View {
        GeometryReader { geometry in
            let boardSize = min(geometry.size.width, geometry.size.height)
            let borderSize = boardSize * 0.95
            
            ZStack {
                
                // Dark border rectangle
                Rectangle()
                    .fill(Color(red: 65/255, green: 65/255, blue: 65/255))
                    .frame(width: geometry.size.width, height: geometry.size.width)
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<8, id: \.self) { col in
                                
                            }
                        }
                    }
                }

                // Centered chessboard inside the border
                ChessBoardView(squareSize: borderSize / 8, color1: color1, color2: color2)
                    .frame(width: borderSize, height: borderSize)
            }
            .frame(width: borderSize, height: borderSize)
            .position(x: geometry.size.width / 2, y: geometry.size.width / 2)
        }
//        .padding()
    }
}

struct ChessBoardView: View {
    var squareSize: CGFloat
    var color1: Color
    var color2: Color
    var columnCoordinates = ["a", "b", "c", "d", "e", "f", "g", "h"]
    var rowCoordinates = ["1", "2", "3", "4", "5", "6", "7", "8"]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { col in
                        ZStack {
                            Rectangle()
                                .fill((row + col) % 2 == 0 ? color1 : color2)
                                .frame(width: squareSize, height: squareSize)
                            
                            GeometryReader { geometry in
                                if row == 0 {
                                    Text(columnCoordinates[col])
                                        .foregroundColor(Color.white)
                                        .position(x: geometry.size.width * 0.5, y: geometry.size.height - 57)
                                        .font(.system(size: 10).bold())
                                }
                                if row == 7 {
                                    Text(columnCoordinates[col])
                                        .foregroundColor(Color.white)
                                        .position(x: geometry.size.width * 0.5, y: geometry.size.height + 4.7)
                                        .font(.system(size: 10).bold())
                                }
                                if col == 0 {
                                    Text(rowCoordinates[7 - row])
                                        .foregroundColor(Color.white)
                                        .position(x: geometry.size.width - 57, y: geometry.size.height * 0.5)
                                        .font(.system(size: 10).bold())
                                }
                                if col == 7 {
                                    Text(rowCoordinates[7 - row])
                                        .foregroundColor(Color.white)
                                        .position(x: geometry.size.width + 6, y: geometry.size.height * 0.5)
                                        .font(.system(size: 10).bold())
                                }
                                
                            }
                        }
                    }
                }
            }
        }
    }
}
