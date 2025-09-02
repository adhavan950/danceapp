//
//  DanceItem.swift
//  lwk dancing
//
//  Created by Adam Zafir on 8/29/25.
//

import Foundation

struct DanceItem {
    var videoLink: String?
    var title: String
    var difficulty: String
}


class allDances: ObservableObject {
    @Published var dances: [DanceItem] = [DanceItem(title: "A dance", difficulty: "Easy")] 
}

//new dances = all dances - recent dances (to be implemented)

class recentDances: ObservableObject {
    @Published var dances: [DanceItem] = [] //add data later
}
