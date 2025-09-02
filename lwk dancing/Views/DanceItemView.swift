//
//  DanceItemView.swift
//  lwk dancing
//
//  Created by Adam Zafir on 9/2/25.
//

import SwiftUI

struct DanceItemView: View {
    let dance: DanceItem
    var body: some View {
        NavigationStack {
            NavigationLink {
                // DetailedDanceView(dance: dance)
                Text("stuf")
            } label: {
                HStack(spacing: 12) {
                    Text(dance.name)
                        .font(.headline)
                    Spacer()
                    if let points = dance.points {
                        Text("\(points)")
                            .font(.subheadline.weight(.semibold))
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 72)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                       // .fill(colooor)
                        .shadow(radius: 3)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 24)
        }
    }
}



#Preview {
    DanceItemView(dance: DanceItem(id: UUID(), videoLink: nil, name: "A dance", difficulty: "Easy", points: 10))
}
