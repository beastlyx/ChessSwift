//
//  GameView.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 8/2/24.
//

import SwiftUI

var countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

struct GameView: View {
    @ObservedObject var matchManager: MatchManager
    @Published var lastReceivedMoveData: MoveData
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .onReceive(countdownTimer) { _ in
            guard matchManager.isTimeKeeper else { return }
            matchManager.remainingTime -= 1
        }
    }
}

#Preview {
    GameView(matchManager: MatchManager())
}
