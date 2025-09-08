//
//  loadingView.swift
//  lwk dancing
//
//  Created by Adhavan senthil kumar on 8/9/25.
//
import SwiftUI

struct loadingView: View {
    let score: Double
    
    var body: some View {
        VStack(spacing: 24) {
            ProgressView("Processing…")
                .progressViewStyle(CircularProgressViewStyle())
                .font(.title2)
                .padding()
            
            Text("Dance similarity score")
                .font(.title2)
                .bold()
            
            Text("\(String(format: "%.1f", score)) / 100")
                .font(.largeTitle)
                .bold()
                .foregroundColor(score > 70 ? .green : .red)
        }
        .padding()
    }
}
