//
//  SideMenuView.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 7/31/24.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var showingEditBoardView: Bool

    var body: some View {
        VStack {

        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingEditBoardView = true
                }, label: {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(Color.blue)
                })
            }
        }
    }
}
