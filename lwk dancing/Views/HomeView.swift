//
//  ContentView.swift
//  lwk dancing
//
//  Created by Adam Zafir on 8/28/25.
//

import SwiftUI

struct HomeView: View {
    @State private var username = "Tim Cook" // temp name until actual username collection
    @State private var recentDances: [String] = ["Dance1", "D2", "D3", "D4", "dfvgnjk", "fdvkjn"] //fake the data till you make the data ahhahaha
    @State private var newDances: [String] = ["Dance1", "D2", "D3", "D4", "dfvgnjk", "fdvkjn"]
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgcol
                    .ignoresSafeArea()
                VStack(alignment: .trailing) {
                    Text("")
                        .font(.title2)
                }
                VStack(alignment: .leading) {
                    Text("Start Dancing")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<newDances.count, id: \.self) { index in
                                let item = newDances[index]
                                
                                NavigationLink {
                                    DanceRecorderView()
                                } label: {
                                    DanceCard(title: item, index: index + 1)
                                        .frame(width: 250, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(radius: 4)
                                }
                            }
                            
                            
                        }
                        .padding(.horizontal)
                    }
                    
                    Text("Recent Dances")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<recentDances.count, id: \.self) { index in
                                let item = recentDances[index]
                                
                                NavigationLink {
                                    DanceRecorderView()
                                } label: {
                                    DanceCard(title: item, index: index)
                                        .frame(width: 250, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(radius: 4)
                                }
                            }
                            
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
                .navigationTitle("Hello \(username),")
                
        
            }
        }
        
    }
}
struct DanceCard: View {
    let title: String
    let index: Int
    
    var body: some View {
        ZStack {
            (index % 2 == 0 ? Color.turq : Color.orag)
            
            Text(title)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView()
}
