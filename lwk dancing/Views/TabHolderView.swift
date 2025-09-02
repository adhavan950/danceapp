//
//  TabHolderView.swift
//  lwk dancing
//
//  Created by Adam Zafir on 9/2/25.
//

import SwiftUI

struct TabHolderView: View {
    var body: some View {
        
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            Tab("Past Dances", systemImage: "figure.dance") {
                DoneDancedView()
            }
            Tab("Settings", systemImage: "gear") {
                Text("Settings")
            }
        
        }
    }
}

#Preview {
    TabHolderView()
}
