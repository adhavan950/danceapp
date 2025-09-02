//
//  DoneDancedView.swift
//  lwk dancing
//
//  Created by Adam Zafir on 9/2/25.
//

import SwiftUI

struct DoneDancedView: View { // shows past dances + stats
    @StateObject private var viewmodel = recentDances()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewmodel.dances) { item in
                    DanceItemView(dance: item)
                }
            }
            .navigationTitle("Past Dances")
        }
    }
}

#Preview {
    DoneDancedView()
}


#Preview {
    DoneDancedView()
}
