//
//  DanceItem.swift
//  lwk dancing
//
//  Created by Adam Zafir on 8/29/25.
//

import Foundation

struct DanceItem: Identifiable {
    var id: UUID
    var videoLink: String?
    var name: String
    var difficulty: String
    var points: Int?
}


class allDances: ObservableObject {
    @Published var dances: [DanceItem] = [DanceItem(id: UUID(), videoLink: nil, name: "A dance", difficulty: "Easy", points: nil)]
}

//new dances = all dances - recent dances (to be implemented)

class recentDances: ObservableObject {
    @Published var dances: [DanceItem] =
    [DanceItem(id: UUID(), videoLink: nil, name: "Moon Walk",        difficulty: "Easy",   points: 10),
     DanceItem(id: UUID(), videoLink: nil, name: "Hip Hop Shuffle",  difficulty: "Medium", points: 25),
     DanceItem(id: UUID(), videoLink: nil, name: "Salsa Spin",       difficulty: "Hard",   points: 40),
     DanceItem(id: UUID(), videoLink: nil, name: "Break Free",       difficulty: "Hard",   points: 50),
     DanceItem(id: UUID(), videoLink: nil, name: "Groove Basics",    difficulty: "Easy",   points: 5),
     DanceItem(id: UUID(), videoLink: nil, name: "Tango Twist",      difficulty: "Medium", points: 30)]
    
}
