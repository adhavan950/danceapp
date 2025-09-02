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
    @Published var dances: [DanceItem] = [] //add data later
}
