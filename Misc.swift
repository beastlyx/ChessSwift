//
//  Misc.swift
//  Chess
//
//  Created by Borys Banaszkiewicz on 8/1/24.
//

import Foundation

let everydayObjects: [String] = [
    "pen", "paper", "book", "table", "chair", "computer", "phone", "keys",
    "wallet", "watch", "clock", "lamp", "bed", "pillow", "blanket", "sofa",
    "TV", "remote", "car", "bicycle", "bus", "train", "plane", "umbrella",
    "sunglasses", "shoe", "pants", "shirt", "hat", "coat", "gloves", "scarf",
    "socks", "toothbrush", "toothpaste", "soap", "shampoo", "conditioner",
    "razor", "towel", "dish", "silverware", "glass", "plate", "microwave",
    "fridge", "stove", "oven", "dishwasher", "washing machine", "dryer",
    "vacuum cleaner", "mop", "broom", "dustpan", "trash can", "laundry basket",
    "hanger", "iron", "hairbrush", "comb", "nail clipper", "scissors", "tape",
    "glue", "stapler", "paperclip", "binder", "folder", "envelope", "post-it note",
    "calendar", "whiteboard", "marker", "eraser", "pencil", "ruler", "compass",
    "protractor", "calculator", "flashlight", "battery", "extension cord",
    "power strip", "plunger", "screwdriver", "hammer", "wrench", "tape measure",
    "level", "pliers", "saw"
]

enum PlayerAuthState: String {
    case authenticating = "Logging into Game Center..."
    case unauthenticated = "Please sign in to Game Center to play."
    case authenticated = ""
    
    case error = "There was an error logging into Game Center."
    case restricted = "You're not allowed to play multiplayer games!"
}

struct PastGuess: Identifiable {
    let id = UUID()
    var message: String
    var correct: Bool
}

let maxTimeRemaining = 600
