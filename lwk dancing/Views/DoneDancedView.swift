//
//  DoneDancedView.swift
//  lwk dancing
//
//  Created by Adam Zafir on 9/2/25.
//

import SwiftUI

struct DoneDancedView: View {
    @StateObject private var viewmodel = recentDances()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgcol.ignoresSafeArea()

                List(viewmodel.dances.indices, id: \.self) { i in
                    let item = viewmodel.dances[i]
                    DanceItemView(dance: item, iindex: i)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .background(.clear)
                .listStyle(.plain)
            }
            .navigationTitle("Past Dances")
        }
    }
}


#Preview {
    DoneDancedView()
}

